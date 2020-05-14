#
# Cookbook:: nginx
# Resource:: nginx_site
#
# Copyright:: 2015, OpenStreetMap Foundation
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

default_action :create

property :site, :kind_of => String, :name_property => true
property :directory, :kind_of => String
property :cookbook, :kind_of => String
property :template, :kind_of => String, :required => [:create]
property :variables, :kind_of => Hash, :default => {}

action :create do
  declare_resource :template, conf_path do
    cookbook new_resource.cookbook
    source new_resource.template
    owner "root"
    group "root"
    mode "644"
    variables new_resource.variables.merge(:name => new_resource.site, :directory => directory)
  end
end

action :delete do
  file conf_path do
    action :delete
    notifies :reload, "service[nginx]"
  end
end

action_class do
  def conf_path
    "/etc/nginx/conf.d/#{new_resource.site}.conf"
  end

  def directory
    new_resource.directory || "/var/www/#{new_resource.site}"
  end
end

def after_created
  notifies :reload, "service[nginx]"
end
