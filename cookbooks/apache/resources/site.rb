#
# Cookbook:: apache
# Resource:: apache_site
#
# Copyright:: 2013, OpenStreetMap Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default_action [:create, :enable]

property :site, :kind_of => String, :name_property => true
property :directory, :kind_of => String
property :cookbook, :kind_of => String
property :template, :kind_of => String, :required => [:create]
property :variables, :kind_of => Hash, :default => {}
property :reload_apache, :kind_of => [TrueClass, FalseClass], :default => true

action :create do
  declare_resource :template, available_name do
    cookbook new_resource.cookbook
    source new_resource.template
    owner "root"
    group "root"
    mode "644"
    variables new_resource.variables.merge(:name => new_resource.site, :directory => site_directory)
  end
end

action :enable do
  link enabled_name do
    to available_name
    owner "root"
    group "root"
  end
end

action :disable do
  link enabled_name do
    action :delete
  end
end

action :delete do
  file available_name do
    action :delete
  end
end

action_class do
  def site_directory
    new_resource.directory || "/var/www/#{new_resource.site}"
  end

  def available_name
    "/etc/apache2/sites-available/#{new_resource.site}.conf"
  end

  def enabled_name
    case new_resource.site
    when "default"
      "/etc/apache2/sites-enabled/000-default.conf"
    else
      "/etc/apache2/sites-enabled/#{new_resource.site}.conf"
    end
  end
end

def after_created
  notifies :reload, "service[apache2]" if reload_apache
end
