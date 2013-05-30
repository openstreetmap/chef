#
# Cookbook Name:: apache
# Definition:: apache_module
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

define :apache_module, :action => [ :install, :enable ], :variables => {} do
  name = params[:name]
  module_action = params[:action]

  if params[:package].nil? or params[:package].empty?
    package_name = "libapache2-mod-#{name}"
  else
    package_name = params[:package]
  end

  if module_action.include?(:install)
    package package_name do
      action :install
      not_if { File.exists?("/etc/apache2/mods-available/#{name}.load") }
    end

    if params[:conf]
      template "/etc/apache2/mods-available/#{name}.conf" do
        source params[:conf]
        owner "root"
        group "root"
        mode 0644
        variables params[:variables]
        if File.exists?("/etc/apache2/mods-enabled/#{name}.load")
          notifies :reload, resources(:service => "apache2")
        end
      end
    end
  end

  if module_action.include?(:enable)
    execute "a2enmod-#{name}" do
      command "/usr/sbin/a2enmod #{name}"
      notifies :restart, resources(:service => "apache2")
      not_if { File.exists?("/etc/apache2/mods-enabled/#{name}.load") }
    end
  elsif module_action.include?(:disable) or module_action.include?(:remove)
    execute "a2dismod-#{name}" do
      command "/usr/sbin/a2dismod #{name}"
      notifies :restart, resources(:service => "apache2")
      only_if { File.exists?("/etc/apache2/mods-enabled/#{name}.load") }
    end
  end

  if module_action.include?(:remove)
    package package_name do
      action :remove
      only_if { File.exists?("/etc/apache2/mods-available/#{name}.load") }
    end
  end
end
