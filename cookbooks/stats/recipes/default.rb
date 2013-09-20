#
# Cookbook Name:: stats
# Recipe:: default
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

include_recipe "apache"

package "awstats"
package "libgeo-ipfree-perl"

node[:stats][:sites].each do |site|
  template "/etc/awstats/awstats.#{site[:name]}.conf" do
    source "awstats.conf.erb"
    owner "root"
    group "root"
    mode 0644
    variables :site => site
  end
end

template "/etc/cron.d/awstats" do
  source "awstats.cron.erb"
  owner "root"
  group "root"
  mode 0644
  variables :sites => node[:stats][:sites]
end

cookbook_file "/usr/local/bin/repack-archived-logs" do
  owner "root"
  group "root"
  mode 0755
end

template "/etc/cron.d/repack-archived-logs" do
  source "repack.cron.erb"
  owner "root"
  group "root"
  mode 0644
end

directory "/srv/stats.openstreetmap.org" do
  owner "root"
  group "root"
  mode 0755
end

template "/srv/stats.openstreetmap.org/index.html" do
  source "index.html.erb"
  owner "root"
  group "root"
  mode 644
  variables :sites => node[:stats][:sites]
end

cookbook_file "/srv/stats.openstreetmap.org/robots.txt" do
  owner "root"
  group "root"
  mode 0644
end

apache_site "stats.openstreetmap.org" do
  template "apache.erb"
  directory "/srv/stats.openstreetmap.org"
end
