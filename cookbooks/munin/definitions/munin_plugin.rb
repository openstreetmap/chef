#
# Cookbook Name:: munin
# Definition:: munin_plugin
#
# Copyright 2010, OpenStreetMap Foundation
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

define :munin_plugin, :action => :create do
  target = params[:target] || params[:name]

  if File.exists?("/usr/local/share/munin/plugins/#{target}")
    target_path = "/usr/local/share/munin/plugins/#{target}"
  elsif File.exists?("/usr/share/munin/plugins/#{target}")
    target_path = "/usr/share/munin/plugins/#{target}"
  else
    target_path = nil
  end

  if target_path.nil? or params[:action] == :delete
    link "/etc/munin/plugins/#{params[:name]}" do
      action :delete
    end
  else
    link "/etc/munin/plugins/#{params[:name]}" do
      action params[:action]
      to target_path
      notifies :restart, resources(:service => "munin-node")
    end
  end

  if params[:conf]
    conf_template = params[:conf]
    conf_cookbook = params[:conf_cookbook]
    conf_variables = params[:conf_variables]

    munin_plugin_conf params[:name] do
      action params[:action]
      template conf_template
      if conf_cookbook
        cookbook conf_cookbook
      end
      if conf_variables
        variables conf_variables
      end
    end
  end
end
