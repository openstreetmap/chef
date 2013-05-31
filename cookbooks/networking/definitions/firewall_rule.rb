#
# Cookbook Name:: networking
# Definition:: firewall_rule
#
# Copyright 2011, OpenStreetMap Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

define :firewall_rule, :action => :accept do
  inet = nil
  inet6 = nil

  begin
    inet = resources(:template => "/etc/shorewall/rules")
    inet6 = resources(:template => "/etc/shorewall6/rules")
  rescue
  end

  rule = Hash[
    :action => params[:action].to_s.upcase,
    :source => params[:source],
    :dest => params[:dest],
    :proto => params[:proto],
    :dest_ports => params[:dest_ports] || "-",
    :source_ports => params[:source_ports] || "-",
    :rate_limit => params[:rate_limit] || "-"
  ]

  if params[:family].nil?
    inet.variables[:rules] << rule unless inet.nil?
    inet6.variables[:rules] << rule unless inet6.nil?
  elsif params[:family].to_s == "inet"
    inet.variables[:rules] << rule unless inet.nil?
  elsif params[:family].to_s == "inet6"
    inet6.variables[:rules] << rule unless inet6.nil?
  else
    log "Unsupported network family" do
      level :error
    end
  end
end
