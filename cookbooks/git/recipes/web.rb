#
# Cookbook Name:: git
# Recipe:: web
#
# Copyright 2013, OpenStreetMap Foundation
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

include_recipe "apache::ssl"

package "gitweb"

apache_module "rewrite"

git_directory = node[:git][:directory]

template "/etc/gitweb.conf" do
  source "gitweb.conf.erb"
  owner "root"
  group "root"
  mode 0o644
end

apache_site node[:git][:host] do
  template "apache.erb"
  directory git_directory
end

template "#{git_directory}/robots.txt" do
  source "robots.txt.erb"
  owner "root"
  group "root"
  mode 0o644
end
