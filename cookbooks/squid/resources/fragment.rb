#
# Cookbook:: squid
# Resource:: squid_fragment
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

property :fragment, :kind_of => String, :name_property => true
property :template, :kind_of => String, :required => [:create]
property :variables, :kind_of => Hash, :default => {}

action :create do
  declare_resource :template, fragment_path do
    source new_resource.template
    owner "root"
    group "root"
    mode "644"
    variables new_resource.variables
  end
end

action :delete do
  file fragment_path do
    action :delete
  end
end

action_class do
  def fragment_path
    "/etc/squid/squid.conf.d/#{new_resource.fragment}.conf"
  end
end

def after_created
  notifies :create, "template[/etc/squid/squid.conf]"
end
