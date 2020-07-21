#
# Cookbook:: git
# Recipe:: web
#
# Copyright:: 2013, OpenStreetMap Foundation
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

include_recipe "apache"

package "gitweb"

apache_module "rewrite"

git_site = node[:git][:host]

template "/etc/gitweb.conf" do
  source "gitweb.conf.erb"
  owner "root"
  group "root"
  mode "644"
end

directory "/srv/#{git_site}" do
  owner "root"
  group "root"
  mode "755"
end

template "/srv/#{git_site}/robots.txt" do
  source "robots.txt.erb"
  owner "root"
  group "root"
  mode "644"
end

ssl_certificate git_site do
  domains [git_site] + Array(node[:git][:aliases])
  notifies :reload, "service[apache2]"
end

private_allowed = search(:node, node[:git][:private_nodes]).collect do |n|
  n.ipaddresses(:role => :external)
end.flatten

apache_site git_site do
  template "apache.erb"
  directory "/srv/#{git_site}"
  variables :aliases => Array(node[:git][:aliases]),
            :private_allowed => private_allowed
end
