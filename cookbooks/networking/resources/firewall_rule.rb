#
# Cookbook:: networking
# Resource:: firewall_rule
#
# Copyright:: 2020, OpenStreetMap Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

resource_name :firewall_rule
provides :firewall_rule

unified_mode true

default_action :nothing

property :rule, :kind_of => String, :name_property => true
property :family, :kind_of => [String, Symbol]
property :source, :kind_of => String, :required => true
property :dest, :kind_of => String, :required => true
property :proto, :kind_of => String, :required => true
property :dest_ports, :kind_of => [String, Integer, Array]
property :source_ports, :kind_of => [String, Integer, Array]
property :rate_limit, :kind_of => String, :default => "-"
property :connection_limit, :kind_of => [String, Integer], :default => "-"
property :helper, :kind_of => String, :default => "-"

property :compile_time, TrueClass, :default => true

action :accept do
  add_rule :accept
end

action :drop do
  add_rule :drop
end

action :reject do
  add_rule :reject
end

action_class do
  def add_rule(action)
    if new_resource.family.nil?
      add_nftables_rule(action, "inet")
      add_nftables_rule(action, "inet6")
    elsif new_resource.family.to_s == "inet"
      add_nftables_rule(action, "inet")
    elsif new_resource.family.to_s == "inet6"
      add_nftables_rule(action, "inet6")
    end
  end

  def add_nftables_rule(action, family)
    rule = []

    ip = case family
         when "inet" then "ip"
         when "inet6" then "ip6"
         end

    proto = new_resource.proto

    if new_resource.source_ports
      rule << "#{proto} sport { #{nftables_source_ports} }"
    end

    if new_resource.dest_ports
      rule << "#{proto} dport { #{nftables_dest_ports} }"
    end

    if new_resource.source == "osm"
      rule << "#{ip} saddr @#{ip}-osm-addresses"
    elsif new_resource.source =~ /^net:(.*)$/
      addresses = Regexp.last_match(1).split(",").join(", ")

      rule << "#{ip} saddr { #{addresses} }"
    end

    if new_resource.dest == "osm"
      rule << "#{ip} daddr @#{ip}-osm-addresses"
    elsif new_resource.dest =~ /^net:(.*)$/
      addresses = Regexp.last_match(1).split(",").join(", ")

      rule << "#{ip} daddr { #{addresses} }"
    end

    rule << "ct state new" if new_resource.proto == "tcp"

    if new_resource.connection_limit != "-"
      set = "connlimit-#{new_resource.rule}-#{ip}"

      node.default[:networking][:firewall][:sets] << set

      rule << "add @#{set} { #{ip} saddr ct count #{new_resource.connection_limit} }"
    end

    if new_resource.rate_limit =~ %r{^s:(\d+)/sec:(\d+)$}
      set = "ratelimit-#{new_resource.rule}-#{ip}"
      rate = Regexp.last_match(1)
      burst = Regexp.last_match(2)

      node.default[:networking][:firewall][:sets] << set

      rule << "update @#{set} { #{ip} saddr limit rate #{rate}/second burst #{burst} packets }"
    end

    rule << case action
            when :accept then "accept"
            when :drop then "jump log-and-drop"
            when :reject then "jump log-and-reject"
            end

    if new_resource.source == "fw"
      node.default[:networking][:firewall][:outgoing] << rule.join(" ")
    elsif new_resource.dest == "fw"
      node.default[:networking][:firewall][:incoming] << rule.join(" ")
    end
  end

  def nftables_source_ports
    Array(new_resource.source_ports).map(&:to_s).join(",")
  end

  def nftables_dest_ports
    Array(new_resource.dest_ports).map(&:to_s).join(",")
  end
end
