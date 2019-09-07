#
# Cookbook:: networking
# Definition:: firewall_rule
#
# Copyright:: 2011, OpenStreetMap Foundation
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

define :firewall_rule, :action => :accept do
  rule = Hash[
    :action => params[:action].to_s.upcase,
    :source => params[:source],
    :dest => params[:dest],
    :proto => params[:proto],
    :dest_ports => params[:dest_ports] || "-",
    :source_ports => params[:source_ports] || "-",
    :rate_limit => params[:rate_limit] || "-",
    :connection_limit => params[:connection_limit] || "-",
    :helper => params[:helper] || "-"
  ]

  if params[:family].nil?
    node.default["networking"]["firewall"]["inet"] << rule
    node.default["networking"]["firewall"]["inet6"] << rule
  elsif params[:family].to_s == "inet"
    node.default["networking"]["firewall"]["inet"] << rule
  elsif params[:family].to_s == "inet6"
    node.default["networking"]["firewall"]["inet6"] << rule
  else
    log "Unsupported network family" do
      level :error
    end
  end
end
