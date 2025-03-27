#
# Cookbook:: community
# Recipe:: default
#
# Copyright:: 2021, OpenStreetMap Foundation
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
include_recipe "docker"
include_recipe "git"
include_recipe "ssl"

passwords = data_bag_item("community", "passwords")
license_keys = data_bag_item("geoipupdate", "license-keys") unless kitchen?

prometheus_servers = search(:node, "recipes:prometheus\\:\\:server").map do |server|
  server.ipaddresses(:role => :external)
end.flatten

# Disable any default installed apache2 service. Web server is embedded within the discourse docker container
service "apache2" do
  action [:disable, :stop]
end

directory "/srv/community.openstreetmap.org" do
  owner "root"
  group "root"
  mode "755"
end

directory "/srv/community.openstreetmap.org/shared" do
  owner "community"
  group "community"
  mode "755"
end

directory "/srv/community.openstreetmap.org/files" do
  owner "community"
  group "community"
  mode "755"
end

template "/srv/community.openstreetmap.org/files/update-feeds.atom" do
  source "update-feeds.atom.erb"
  owner "community"
  group "community"
  mode "644"
end

git "/srv/community.openstreetmap.org/docker" do
  action :sync
  repository "https://github.com/discourse/discourse_docker.git"
  # DANGER launch wrapper automatically updates git repo if rebuild method used: https://github.com/discourse/discourse_docker/blob/107ffb40fe8b1ea40e00814468db974a4f3f8e8f/launcher#L799
  revision "e42fa9711e9a8b27e9618342b5b456d3ba5b8025"
  user "root"
  group "root"
  notifies :run, "notify_group[discourse_container_new_data]"
  notifies :run, "notify_group[discourse_container_new_web_only]"
  notifies :run, "notify_group[discourse_container_new_mail_receiver]"
end

template "/srv/community.openstreetmap.org/docker/containers/data.yml" do
  source "data.yml.erb"
  owner "root"
  group "root"
  mode "640"
  variables :passwords => passwords
  notifies :run, "notify_group[discourse_container_new_data]"
end

resolvers = node[:networking][:nameservers].map do |resolver|
  resolver =~ /:/ ? "[#{resolver}]" : resolver
end

template "/srv/community.openstreetmap.org/docker/containers/web_only.yml" do
  source "web_only.yml.erb"
  owner "root"
  group "root"
  mode "640"
  variables :license_keys => license_keys, :passwords => passwords,
            :prometheus_servers => prometheus_servers, :resolvers => resolvers
  notifies :run, "notify_group[discourse_container_new_web_only]"
end

template "/srv/community.openstreetmap.org/files/policyd-spf.conf" do
  source "policyd-spf.conf.erb"
  owner "community"
  group "community"
  mode "644"
  notifies :run, "notify_group[discourse_container_new_mail_receiver]"
end

template "/srv/community.openstreetmap.org/docker/containers/mail-receiver.yml" do
  source "mail-receiver.yml.erb"
  owner "root"
  group "root"
  mode "640"
  variables :passwords => passwords
  notifies :run, "notify_group[discourse_container_new_mail_receiver]"
end

ssl_certificate "community.openstreetmap.org" do
  domains ["community.openstreetmap.org", "community.osm.org", "communities.openstreetmap.org", "communities.osm.org", "c.openstreetmap.org", "c.osm.org", "forum.openstreetmap.org", "forum.osm.org"]
  notifies :run, "notify_group[discourse_container_new_web_only]"
  notifies :run, "notify_group[discourse_container_new_mail_receiver]"
end

notify_group "discourse_container_new_web_only" do
  notifies :run, "execute[discourse_container_data_start]", :immediately # noop if site up
  notifies :run, "execute[discourse_container_web_only_bootstrap]", :immediately # site up but runs in parallel. Slow
  notifies :run, "execute[discourse_container_web_only_destroy]", :immediately # site down
  notifies :run, "execute[discourse_container_data_destroy]", :immediately # site down
  notifies :run, "execute[discourse_container_data_bootstrap]", :immediately # site down
  notifies :run, "execute[discourse_container_data_start]", :immediately # site down
  notifies :run, "execute[discourse_container_web_only_start]", :immediately # site restore
end

notify_group "discourse_container_new_data" do
  notifies :run, "execute[discourse_container_web_only_destroy]", :immediately # site down
  notifies :run, "execute[discourse_container_data_destroy]", :immediately # site down
  notifies :run, "execute[discourse_container_data_bootstrap]", :immediately # site down
  notifies :run, "execute[discourse_container_data_start]", :immediately # site down
  notifies :run, "execute[discourse_container_web_only_start]", :immediately # site restore
end

notify_group "discourse_container_new_mail_receiver" do
  notifies :run, "execute[discourse_container_mail_receiver_destroy]", :immediately
  notifies :run, "execute[discourse_container_mail_receiver_bootstrap]", :immediately
  notifies :run, "execute[discourse_container_mail_receiver_start]", :immediately
end

# Attempt at a failsafe to ensure all containers are running
notify_group "discourse_container_ensure_all_running" do
  action :run
  notifies :run, "execute[discourse_container_data_start]", :delayed
  notifies :run, "execute[discourse_container_web_only_start]", :delayed
  notifies :run, "execute[discourse_container_mail_receiver_start]", :delayed
end

execute "discourse_container_data_bootstrap" do
  action :nothing
  command "./launcher bootstrap data"
  cwd "/srv/community.openstreetmap.org/docker/"
  user "root"
  group "root"
  retries 2 # Postgres upgrades required a second run
end

execute "discourse_container_data_destroy" do
  action :nothing
  command "./launcher destroy data"
  cwd "/srv/community.openstreetmap.org/docker/"
  user "root"
  group "root"
end

execute "discourse_container_data_start" do
  action :nothing
  command "./launcher start data"
  cwd "/srv/community.openstreetmap.org/docker/"
  user "root"
  group "root"
end

execute "discourse_container_web_only_bootstrap" do
  action :nothing
  command "./launcher bootstrap web_only"
  cwd "/srv/community.openstreetmap.org/docker/"
  user "root"
  group "root"
end

execute "discourse_container_web_only_destroy" do
  action :nothing
  command "./launcher destroy web_only"
  cwd "/srv/community.openstreetmap.org/docker/"
  user "root"
  group "root"
end

execute "discourse_container_web_only_start" do
  action :nothing
  command "./launcher start web_only"
  cwd "/srv/community.openstreetmap.org/docker/"
  user "root"
  group "root"
end

execute "discourse_container_mail_receiver_bootstrap" do
  action :nothing
  command "./launcher bootstrap mail-receiver"
  cwd "/srv/community.openstreetmap.org/docker/"
  user "root"
  group "root"
end

execute "discourse_container_mail_receiver_destroy" do
  action :nothing
  command "./launcher destroy mail-receiver"
  cwd "/srv/community.openstreetmap.org/docker/"
  user "root"
  group "root"
end

execute "discourse_container_mail_receiver_start" do
  action :nothing
  command "./launcher start mail-receiver"
  cwd "/srv/community.openstreetmap.org/docker/"
  user "root"
  group "root"
end

template "/etc/cron.daily/community-backup" do
  source "backup.cron.erb"
  owner "root"
  group "root"
  mode "750"
end

node.default[:prometheus][:exporters][443] = {
  :name => "community",
  :address => "#{node[:prometheus][:address]}:443",
  :sni => "community.openstreetmap.org"
}
