#
# Cookbook Name:: dns
# Recipe:: default
#
# Copyright 2011, OpenStreetMap Foundation
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

include_recipe "git"
include_recipe "apache"

passwords = data_bag_item("dns", "passwords")

package "make"

package "perl"
package "libxml-treebuilder-perl"
package "libxml-writer-perl"
package "libyaml-perl"
package "libwww-perl"
package "libjson-xs-perl"

directory "/srv/dns.openstreetmap.org" do
  owner "root"
  group "root"
  mode 0755
end

remote_directory "/srv/dns.openstreetmap.org/html" do
  source "html"
  owner "root"
  group "root"
  mode 0755
  files_owner "root"
  files_group "root"
  files_mode 0644
end

zones = Array.new

Dir.glob("/var/lib/dns/json/*.json").each do |kmlfile|
  zone = File.basename(kmlfile, ".json")

  template "/srv/dns.openstreetmap.org/html/#{zone}.html" do
    source "zone.html.erb"
    owner "root"
    group "root"
    mode 0644
    variables :zone => zone
  end

  zones.push(zone)
end

template "/srv/dns.openstreetmap.org/html/index.html" do
  source "index.html.erb"
  owner "root"
  group "root"
  mode 0644
  variables :zones => zones
end

apache_site "dns.openstreetmap.org" do
  template "apache.erb"
  directory "/srv/dns.openstreetmap.org"
end

template "/usr/local/bin/dns-update" do
  source "dns-update.erb"
  owner "root"
  group "git"
  mode 0750
  variables :passwords => passwords
end

execute "dns-update" do
  action :nothing
  command "/usr/local/bin/dns-update"
  user "git"
  group "git"
end

directory "/var/lib/dns" do
  owner "git"
  group "git"
  mode 02775
  notifies :run, "execute[dns-update]"
end

cookbook_file "#{node[:dns][:repository]}/hooks/post-receive" do
  source "post-receive"
  owner "git"
  group "git"
  mode 0750
end

template "/usr/local/bin/dns-check" do
  source "dns-check.erb"
  owner "root"
  group "git"
  mode 0750
  variables :passwords => passwords
end

template "/etc/cron.d/dns" do
  source "cron.erb"
  owner "root"
  group "root"
  mode 0644
end
