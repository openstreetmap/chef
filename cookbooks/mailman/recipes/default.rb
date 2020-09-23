#
# Cookbook:: mailman
# Recipe:: default
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

require "securerandom"

include_recipe "apache"

package %w[
  locales-all
  mailman
]

subscribe_form_secret = persistent_token("mailman", "subscribe_form_secret")

template "/etc/mailman/mm_cfg.py" do
  source "mm_cfg.py.erb"
  user "root"
  group "root"
  mode "644"
  variables :subscribe_form_secret => subscribe_form_secret
  notifies :restart, "service[mailman]"
end

execute "newlist" do
  command "newlist -q mailman mailman@example.com mailman"
  user "root"
  group "root"
  not_if { ::File.exist?("/var/lib/mailman/lists/mailman/") }
end

service "mailman" do
  action [:enable, :start]
  supports :restart => true, :reload => true
end

apache_module "expires"
apache_module "rewrite"

ssl_certificate "lists.openstreetmap.org" do
  domains ["lists.openstreetmap.org", "lists.osm.org"]
  notifies :reload, "service[apache2]"
end

apache_site "lists.openstreetmap.org" do
  template "apache.erb"
  directory "/srv/lists.openstreetmap.org"
  variables :aliases => ["lists.osm.org"]
end

template "/etc/cron.daily/lists-backup" do
  source "backup.cron.erb"
  owner "root"
  group "root"
  mode "755"
end
