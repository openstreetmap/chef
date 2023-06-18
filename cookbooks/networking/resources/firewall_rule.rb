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

require "ipaddr"

resource_name :firewall_rule
provides :firewall_rule

unified_mode true

default_action :nothing

property :rule, :kind_of => String, :name_property => true
property :context, :kind_of => Symbol, :required => true, :is => [:incoming, :outgoing]
property :protocol, :kind_of => Symbol, :required => true, :is => [:udp, :tcp]
property :source, :kind_of => [String, Symbol, Array]
property :dest, :kind_of => [String, Symbol, Array]
property :dest_ports, :kind_of => [String, Integer, Array]
property :source_ports, :kind_of => [String, Integer, Array]
property :rate_limit, :kind_of => String
property :connection_limit, :kind_of => [String, Integer]
property :helper, :kind_of => String

property :compile_time, TrueClass, :default => true

action :accept do
  add_rule(:accept, "ip")
  add_rule(:accept, "ip6")
end

action :drop do
  add_rule(:drop, "ip")
  add_rule(:drop, "ip6")
end

action :reject do
  add_rule(:reject, "ip")
  add_rule(:reject, "ip6")
end

action_class do
  def add_rule(action, ip)
    rule = []

    protocol = new_resource.protocol.to_s

    source = addresses(new_resource.source, ip)
    dest = addresses(new_resource.dest, ip)

    return if new_resource.source && source.empty?
    return if new_resource.dest && dest.empty?

    rule << "#{protocol} sport #{format_ports(new_resource.source_ports)}"  if new_resource.source_ports
    rule << "#{protocol} dport #{format_ports(new_resource.dest_ports)}" if new_resource.dest_ports
    rule << "#{ip} saddr #{format_addresses(source, ip)}" if new_resource.source
    rule << "#{ip} daddr #{format_addresses(dest, ip)}" if new_resource.dest
    rule << "ct state new" if new_resource.protocol == :tcp

    if new_resource.connection_limit
      set = "connlimit-#{new_resource.rule}-#{ip}"

      node.default[:networking][:firewall][:sets] << {
        :name => set, :type => set_type(ip), :flags => %w[dynamic]
      }

      rule << "add @#{set} { #{ip} saddr ct count #{new_resource.connection_limit} }"
    end

    if new_resource.rate_limit =~ %r{^s:(\d+)/sec:(\d+)$}
      set = "ratelimit-#{new_resource.rule}-#{ip}"
      rate = Regexp.last_match(1)
      burst = Regexp.last_match(2)

      node.default[:networking][:firewall][:sets] << {
        :name => set, :type => set_type(ip), :flags => %w[dynamic], :timeout => 120
      }

      rule << "update @#{set} { #{ip} saddr limit rate #{rate}/second burst #{burst} packets }"
    end

    if new_resource.helper
      helper = "#{new_resource.rule}-#{new_resource.helper}"

      node.default[:networking][:firewall][:helpers] << {
        :name => helper, :helper => new_resource.helper, :protocol => protocol
      }

      rule << "ct helper set #{helper}"
    end

    rule << case action
            when :accept then "accept"
            when :drop then "jump log-and-drop"
            when :reject then "jump log-and-reject"
            end

    node.default[:networking][:firewall][new_resource.context] << rule.join(" ")
  end

  def addresses(addresses, ip)
    if addresses.is_a?(Symbol)
      addresses
    else
      Array(addresses).map do |address|
        if ip == "ip" && IPAddr.new(address.to_s).ipv4?
          address
        elsif ip == "ip6" && IPAddr.new(address.to_s).ipv6?
          address
        end
      end.compact
    end
  end

  def format_ports(ports)
    "{ #{Array(ports).map(&:to_s).join(', ')} }"
  end

  def format_addresses(addresses, ip)
    if addresses.is_a?(Symbol)
      "@#{ip}-#{addresses}-addresses"
    else
      "{ #{Array(addresses).map(&:to_s).join(', ')} }"
    end
  end

  def set_type(ip)
    case ip
    when "ip" then "ipv4_addr"
    when "ip6" then "ipv6_addr"
    end
  end
end
