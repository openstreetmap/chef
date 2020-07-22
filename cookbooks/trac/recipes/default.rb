#
# Cookbook:: trac
# Recipe:: default
#
# Copyright:: 2012, OpenStreetMap Foundation
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

include_recipe "accounts"
include_recipe "apache"

package %w[
  trac
  ruby
]

site_name = "trac.openstreetmap.org"
site_directory = "/srv/#{site_name}"

directory "/var/lib/trac" do
  owner "trac"
  group "trac"
  mode "755"
end

execute "trac-initenv-#{site_name}" do
  command "trac-admin /var/lib/trac initenv #{site_name} sqlite:db/trac.db"
  user "trac"
  group "trac"
  not_if { ::File.exist?("/var/lib/trac/VERSION") }
end

template "/var/lib/trac/conf/trac.ini" do
  source "trac.ini.erb"
  owner "trac"
  group "www-data"
  mode "644"
  variables :name => site_name
end

remote_directory "/var/lib/trac/htdocs" do
  source "htdocs"
  owner "trac"
  group "trac"
  mode "755"
  files_owner "trac"
  files_group "trac"
  files_mode "644"
  purge true
end

remote_directory "/var/lib/trac/templates" do
  source "templates"
  owner "trac"
  group "trac"
  mode "755"
  files_owner "trac"
  files_group "trac"
  files_mode "644"
  purge true
end

execute "trac-deploy-#{site_name}" do
  command "trac-admin /var/lib/trac deploy #{site_directory}"
  user "root"
  group "root"
  not_if { ::File.exist?(site_directory) }
end

cookbook_file "/usr/local/bin/trac-authenticate" do
  owner "root"
  group "root"
  mode "755"
end

apache_module "wsgi"

apache_module "authnz_external" do
  package "libapache2-mod-authnz-external"
end

ssl_certificate "trac.openstreetmap.org" do
  domains ["trac.openstreetmap.org", "trac.osm.org"]
  notifies :reload, "service[apache2]"
end

apache_site site_name do
  template "apache.erb"
  directory site_directory
  variables :user => "trac", :group => "trac", :aliases => ["trac.osm.org"]
end

template "/etc/sudoers.d/trac" do
  source "sudoers.erb"
  owner "root"
  group "root"
  mode "440"
end

template "/etc/cron.daily/trac-backup" do
  source "backup.cron.erb"
  owner "root"
  group "root"
  mode "755"
end
