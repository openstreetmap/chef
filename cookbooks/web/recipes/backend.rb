#
# Cookbook:: web
# Recipe:: backend
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

node.default[:memcached][:ip_address] = node.internal_ipaddress

include_recipe "memcached"
include_recipe "apache"
include_recipe "web::rails"
include_recipe "web::cgimap"

web_passwords = data_bag_item("web", "passwords")

apache_module "remoteip"
apache_module "rewrite"
apache_module "proxy"
apache_module "proxy_fcgi"
apache_module "setenvif"

apache_site "default" do
  action [:disable]
end

apache_site "www.openstreetmap.org" do
  template "apache.backend.erb"
  variables :status => node[:web][:status],
            :secret_key_base => web_passwords["secret_key_base"]
end

service "rails-jobs@storage" do
  action [:disable, :stop]
end

service "rails-jobs@traces" do
  action [:disable, :stop]
end
