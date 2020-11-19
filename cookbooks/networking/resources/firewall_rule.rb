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

default_action :nothing

property :rule, :kind_of => String, :name_property => true
property :family, :kind_of => [String, Symbol]
property :source, :kind_of => String, :required => true
property :dest, :kind_of => String, :required => true
property :proto, :kind_of => String, :required => true
property :dest_ports, :kind_of => [String, Integer], :default => "-"
property :source_ports, :kind_of => [String, Integer], :default => "-"
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
    rule = {
      :action => action.to_s.upcase,
      :source => new_resource.source,
      :dest => new_resource.dest,
      :proto => new_resource.proto,
      :dest_ports => new_resource.dest_ports.to_s,
      :source_ports => new_resource.source_ports.to_s,
      :rate_limit => new_resource.rate_limit,
      :connection_limit => new_resource.connection_limit.to_s,
      :helper => new_resource.helper
    }

    if new_resource.family.nil?
      node.default[:networking][:firewall][:inet] << rule
      node.default[:networking][:firewall][:inet6] << rule
    elsif new_resource.family.to_s == "inet"
      node.default[:networking][:firewall][:inet] << rule
    elsif new_resource.family.to_s == "inet6"
      node.default[:networking][:firewall][:inet6] << rule
    else
      log "Unsupported network family" do
        level :error
      end
    end
  end
end
