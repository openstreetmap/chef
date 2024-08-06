#
# Cookbook:: apt
# Recipe:: repository
#
# Copyright:: 2024, Tom Hughes
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

node.default[:accounts][:users][:apt][:status] = :role

include_recipe "accounts"
include_recipe "apache"

package "aptly"

repository_keys = data_bag_item("apt", "repository")

gpg_passphrase = repository_keys["gpg_passphrase"]

template "/etc/aptly.conf" do
  source "aptly.conf.erb"
  owner "root"
  group "root"
  mode "644"
end

directory "/srv/apt.openstreetmap.org" do
  owner "apt"
  group "apt"
  mode "755"
end

execute "apt-generate-key" do
  command "gpg --no-tty --batch --passphrase=#{gpg_passphrase} --generate-key"
  cwd "/srv/apt.openstreetmap.org"
  user "apt"
  group "apt"
  environment "HOME" => "/srv/apt.openstreetmap.org"
  input <<~EOS
    Key-Type: RSA
    Key-Length: 4096
    Key-Usage: sign
    Subkey-Type: RSA
    Subkey-Length: 4096
    Subkey-Usage: sign
    Name-Real: OpenStreetMap Admins
    Name-Email: admins@openstreetmap.org
    Expire-Date: 0
    Passphrase: #{gpg_passphrase}
  EOS
  not_if { ::Dir.exist?("/srv/apt.openstreetmap.org/.gnupg") }
end

%w[focal jammy noble bookworm].each do |distribution|
  repository = "openstreetmap-#{distribution}"

  execute "aptly-repo-create-#{distribution}" do
    command "aptly repo create -comment='Packages used on OpenStreetMap Servers' -distribution=#{distribution} #{repository}"
    cwd "/srv/apt.openstreetmap.org"
    user "apt"
    group "apt"
    environment "HOME" => "/srv/apt.openstreetmap.org"
    not_if "aptly repo show #{repository}"
  end

  execute "aptly-publish-repo-#{distribution}" do
    action :nothing
    command "aptly publish repo -batch -passphrase=#{gpg_passphrase} #{repository}"
    cwd "/srv/apt.openstreetmap.org"
    user "apt"
    group "apt"
    environment "HOME" => "/srv/apt.openstreetmap.org"
    subscribes :run, "execute[aptly-repo-create-#{distribution}]", :immediately
  end

  execute "aptly-publish-update-#{distribution}" do
    command "aptly publish update -batch -passphrase=#{gpg_passphrase} #{distribution}"
    cwd "/srv/apt.openstreetmap.org"
    user "apt"
    group "apt"
    environment "HOME" => "/srv/apt.openstreetmap.org"
  end
end

execute "gpg-export-key" do
  command "gpg --no-tty --batch --passphrase=#{gpg_passphrase} --armor --output=/srv/apt.openstreetmap.org/public/gpg.key --export admins@openstreetmap.org"
  cwd "/srv/apt.openstreetmap.org"
  user "apt"
  group "apt"
  environment "HOME" => "/srv/apt.openstreetmap.org"
  not_if { ::File.exist?("/srv/apt.openstreetmap.org/public/gpg.key") }
end

ssl_certificate "apt.openstreetmap.org" do
  domains ["apt.openstreetmap.org", "apt.osm.org"]
  notifies :reload, "service[apache2]"
end

apache_site "apt.openstreetmap.org" do
  template "apache.erb"
  directory "/srv/apt.openstreetmap.org"
  variables :aliases => ["apt.osm.org"]
end
