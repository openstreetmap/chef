#
# Cookbook Name:: letsencrypt
# Recipe:: default
#
# Copyright 2017, OpenStreetMap Foundation
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

keys = data_bag_item("chef", "keys")

package %w[
  certbot
  ruby
]

directory "/etc/letsencrypt" do
  owner "letsencrypt"
  group "letsencrypt"
  mode 0o755
end

directory "/var/lib/letsencrypt" do
  owner "letsencrypt"
  group "letsencrypt"
  mode 0o755
end

directory "/var/log/letsencrypt" do
  owner "letsencrypt"
  group "letsencrypt"
  mode 0o700
end

directory "/srv/acme.openstreetmap.org" do
  owner "letsencrypt"
  group "letsencrypt"
  mode 0o755
end

directory "/srv/acme.openstreetmap.org/html" do
  owner "letsencrypt"
  group "letsencrypt"
  mode 0o755
end

ssl_certificate "acme.openstreetmap.org" do
  domains ["acme.openstreetmap.org", "acme.osm.org"]
  notifies :reload, "service[apache2]"
end

apache_site "acme.openstreetmap.org" do
  template "apache.erb"
  directory "/srv/acme.openstreetmap.org"
end

directory "/srv/acme.openstreetmap.org/config" do
  owner "letsencrypt"
  group "letsencrypt"
  mode 0o755
end

directory "/srv/acme.openstreetmap.org/work" do
  owner "letsencrypt"
  group "letsencrypt"
  mode 0o755
end

directory "/srv/acme.openstreetmap.org/logs" do
  owner "letsencrypt"
  group "letsencrypt"
  mode 0o700
end

directory "/srv/acme.openstreetmap.org/.chef" do
  owner "letsencrypt"
  group "letsencrypt"
  mode 0o2775
end

file "/srv/acme.openstreetmap.org/.chef/client.pem" do
  content keys["letsencrypt"].join("\n")
  owner "letsencrypt"
  group "letsencrypt"
  mode 0o660
end

cookbook_file "/srv/acme.openstreetmap.org/.chef/knife.rb" do
  source "knife.rb"
  owner "letsencrypt"
  group "letsencrypt"
  mode 0o660
end

remote_directory "/srv/acme.openstreetmap.org/bin" do
  source "bin"
  owner "root"
  group "root"
  mode 0o755
  files_owner "root"
  files_group "root"
  files_mode 0o755
end

directory "/srv/acme.openstreetmap.org/requests" do
  owner "root"
  group "root"
  mode 0o755
end

certificates = search(:node, "letsencrypt:certificates").each_with_object({}) do |n, c|
  c.merge!(n[:letsencrypt][:certificates])
end

certificates.each do |name, details|
  template "/srv/acme.openstreetmap.org/requests/#{name}" do
    source "request.erb"
    owner "root"
    group "letsencrypt"
    mode 0o754
    variables details
  end

  execute "/srv/acme.openstreetmap.org/requests/#{name}" do
    action :nothing
    command "/srv/acme.openstreetmap.org/requests/#{name}"
    cwd "/srv/acme.openstreetmap.org"
    user "letsencrypt"
    group "letsencrypt"
    subscribes :run, "template[/srv/acme.openstreetmap.org/requests/#{name}]"
  end
end

template "/etc/cron.d/letsencrypt" do
  source "cron.erb"
  owner "root"
  group "root"
  mode 0o644
end
