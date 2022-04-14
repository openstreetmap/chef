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

include_recipe "docker"
include_recipe "git"
include_recipe "ssl"
include_recipe "geoipupdate"

passwords = data_bag_item("community", "passwords")
license_keys = data_bag_item("geoipupdate", "license-keys")

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

git "/srv/community.openstreetmap.org/docker" do
  action :sync
  repository "https://github.com/discourse/discourse_docker.git"
  revision "main"
  depth 1
  user "root"
  group "root"
  notifies :run, "execute[discourse_container_data_rebuild]"
  notifies :run, "execute[discourse_container_web_only_bootstrap]"
  notifies :run, "execute[discourse_container_mail_receiver_rebuild]"
end

template "/srv/community.openstreetmap.org/docker/containers/data.yml" do
  source "data.yml.erb"
  owner "root"
  group "root"
  mode "644"
  variables :passwords => passwords
  notifies :run, "execute[discourse_container_data_rebuild]"
end

template "/srv/community.openstreetmap.org/docker/containers/web_only.yml" do
  source "web_only.yml.erb"
  owner "root"
  group "root"
  mode "644"
  variables :license_keys => license_keys, :passwords => passwords
  notifies :run, "execute[discourse_container_web_only_bootstrap]"
end

template "/srv/community.openstreetmap.org/docker/containers/mail-receiver.yml" do
  source "mail-receiver.yml.erb"
  owner "root"
  group "root"
  mode "644"
  variables :passwords => passwords
  notifies :run, "execute[discourse_container_mail_receiver_rebuild]"
end

# Destroy Bootstap Start
execute "discourse_container_data_rebuild" do
  action :nothing
  command "./launcher rebuild data"
  cwd "/srv/community.openstreetmap.org/docker/"
  user "root"
  group "root"
end

ssl_certificate "community.openstreetmap.org" do
  domains ["community.openstreetmap.org", "community.osm.org", "communities.openstreetmap.org", "communities.osm.org"]
  notifies :run, "execute[discourse_container_web_only_bootstrap]"
end

execute "discourse_container_data_start" do
  action :run
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
  notifies :run, "execute[discourse_container_web_only_destroy]", :immediately
end

execute "discourse_container_web_only_destroy" do
  action :nothing
  command "./launcher destroy web_only"
  cwd "/srv/community.openstreetmap.org/docker/"
  user "root"
  group "root"
  notifies :run, "execute[discourse_container_web_only_start]", :immediately
end

execute "discourse_container_web_only_start" do
  action :run
  command "./launcher start web_only"
  cwd "/srv/community.openstreetmap.org/docker/"
  user "root"
  group "root"
  notifies :run, "execute[discourse_container_data_start]", :before
end

# Destroy Bootstap Start
execute "discourse_container_mail_receiver_rebuild" do
  action :nothing
  command "./launcher rebuild mail-receiver"
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
