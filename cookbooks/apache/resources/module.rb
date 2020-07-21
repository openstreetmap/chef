#
# Cookbook:: apache
# Resource:: apache_module
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

default_action [:install, :enable]

property :module, :kind_of => String, :name_property => true
property :package, :kind_of => String
property :conf, :kind_of => String
property :variables, :kind_of => Hash, :default => {}
property :restart_apache, :kind_of => [TrueClass, FalseClass], :default => true

action :install do
  declare_resource :package, package_name unless installed?

  if new_resource.conf
    template available_name("conf") do
      source new_resource.conf
      owner "root"
      group "root"
      mode "644"
      variables new_resource.variables
    end
  end
end

action :enable do
  execute "a2enmod-#{new_resource.module}" do
    command "a2enmod #{new_resource.module}"
    user "root"
    group "root"
    not_if { ::File.exist?(enabled_name("load")) }
  end

  link enabled_name("load") do
    to available_name("load")
    owner "root"
    group "root"
  end

  link enabled_name("conf") do
    to available_name("conf")
    owner "root"
    group "root"
    only_if { ::File.exist?(available_name("conf")) }
  end
end

action :disable do
  link enabled_name("load") do
    action :delete
  end

  link enabled_name("conf") do
    action :delete
  end
end

action :delete do
  package package_name do
    action :remove
  end
end

action_class do
  def package_name
    new_resource.package || "libapache2-mod-#{new_resource.module}"
  end

  def available_name(extension)
    "/etc/apache2/mods-available/#{new_resource.module}.#{extension}"
  end

  def enabled_name(extension)
    "/etc/apache2/mods-enabled/#{new_resource.module}.#{extension}"
  end

  def installed?
    ::File.exist?(available_name("load"))
  end
end

def after_created
  notifies :restart, "service[apache2]" if restart_apache
end
