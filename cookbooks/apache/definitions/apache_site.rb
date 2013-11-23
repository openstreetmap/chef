#
# Cookbook Name:: apache
# Definition:: apache_site
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

define :apache_site, :action => [ :create, :enable ], :variables => {} do
  name = params[:name]
  directory = params[:directory] || "/var/www/#{name}"
  site_action = params[:action]
  link_name = name == "default" ? "000-default" : name

  if site_action.include?(:create) or site_action.include?(:enable)
    template "/etc/apache2/sites-available/#{name}" do
      cookbook params[:cookbook]
      source params[:template]
      owner "root"
      group "root"
      mode 0644
      variables params[:variables].merge(:name => name, :directory => directory)
      if File.exists?("/etc/apache2/sites-enabled/#{link_name}")
        notifies :reload, "service[apache2]"
      end
    end
  end

  if site_action.include?(:enable)
    execute "a2ensite-#{name}" do
      command "/usr/sbin/a2ensite #{name}"
      notifies :restart, "service[apache2]"
      not_if { File.exists?("/etc/apache2/sites-enabled/#{link_name}") }
    end
  elsif site_action.include?(:disable) or site_action.include?(:delete)
    execute "a2dissite-#{name}" do
      action :run
      command "/usr/sbin/a2dissite #{name}"
      notifies :restart, "service[apache2]"
      only_if { File.exists?("/etc/apache2/sites-enabled/#{link_name}") }
    end
  end

  if site_action.include?(:delete)
    file "/etc/apache2/sites-available/#{name}" do
      action :delete
    end
  end
end
