#
# Cookbook:: otrs
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
include_recipe "exim"
include_recipe "postgresql"
include_recipe "tools"

passwords = data_bag_item("otrs", "passwords")

package "libapache2-mod-perl2"
package "libapache2-reload-perl"

package %w[
  tar
  bzip2
  libapache-dbi-perl
  libarchive-zip-perl
  libauthen-ntlm-perl
  libauthen-sasl-perl
  libcrypt-eksblowfish-perl
  libcss-minifier-xs-perl
  libdatetime-perl
  libdbd-mysql-perl
  libencode-hanextra-perl
  libexcel-writer-xlsx-perl
  libgd-gd2-perl
  libgd-graph-perl
  libgd-text-perl
  libhtml-parser-perl
  libio-socket-ssl-perl
  libjavascript-minifier-xs-perl
  libjson-perl
  libjson-xs-perl
  liblocale-codes-perl
  libmail-imapclient-perl
  libmoo-perl
  libnet-dns-perl
  libnet-ldap-perl
  libpdf-api2-perl
  libsisimai-perl
  libsoap-lite-perl
  libspreadsheet-xlsx-perl
  libtemplate-perl
  libtext-csv-xs-perl
  libtext-diff-perl
  libtimedate-perl
  libxml-libxml-perl
  libxml-libxml-simple-perl
  libxml-libxslt-perl
  libxml-parser-perl
  libxml-simple-perl
  libyaml-libyaml-perl
  libyaml-perl
]

apache_module "headers"

version = node[:otrs][:version]
user = node[:otrs][:user]
database_cluster = node[:otrs][:database_cluster]
database_name = node[:otrs][:database_name]
database_user = node[:otrs][:database_user]
database_password = passwords[node[:otrs][:database_password]]
site = node[:otrs][:site]
site_aliases = node[:otrs][:site_aliases] || []

postgresql_user database_user do
  cluster database_cluster
  password database_password
end

postgresql_database database_name do
  cluster database_cluster
  owner database_user
end

remote_file "#{Chef::Config[:file_cache_path]}/znuny-#{version}.tar.bz2" do
  source "https://download.znuny.org/releases/znuny-#{version}.tar.bz2"
  not_if { ::File.exist?("/opt/znuny-#{version}") }
end

execute "untar-znuny-#{version}" do
  command "tar jxf #{Chef::Config[:file_cache_path]}/znuny-#{version}.tar.bz2"
  cwd "/opt"
  user "root"
  group "root"
  not_if { ::File.exist?("/opt/znuny-#{version}") }
end

config = edit_file "/opt/znuny-#{version}/Kernel/Config.pm.dist" do |line|
  line.gsub!(/^( *)\$Self->{Database} = 'otrs'/, "\\1$Self->{Database} = '#{database_name}'")
  line.gsub!(/^( *)\$Self->{DatabaseUser} = 'otrs'/, "\\1$Self->{DatabaseUser} = '#{database_user}'")
  line.gsub!(/^( *)\$Self->{DatabasePw} = 'some-pass'/, "\\1$Self->{DatabasePw} = '#{database_password}'")
  line.gsub!(/^( *)\$Self->{Database} = 'otrs'/, "\\1$Self->{Database} = '#{database_name}'")
  line.gsub!(/^( *\$Self->{DatabaseDSN} = "DBI:mysql:)/, "#\\1")
  line.gsub!(/^#( *\$Self->{DatabaseDSN} = "DBI:Pg:.*;host=)/, "\\1")
  line.gsub!(/^( *)# (\$Self->{CheckMXRecord} = 0)/, "\\1\\2")
  line.gsub!(/^( *)# \$Self->{SessionUseCookie} = 0/, "\\1$Self->{SessionCheckRemoteIP} = 0")

  line
end

file "/opt/znuny-#{version}/Kernel/Config.pm" do
  owner user
  group "www-data"
  mode "664"
  content config
end

link "/opt/otrs" do
  to "/opt/znuny-#{version}"
end

execute "/opt/otrs/bin/otrs.SetPermissions.pl" do
  action :run
  command "/opt/otrs/bin/otrs.SetPermissions.pl --otrs-user=#{user} --web-group=www-data /opt/otrs-#{version}"
  user "root"
  group "root"
  only_if { File.stat("/opt/otrs/README.md").uid != Etc.getpwnam("otrs").uid }
end

systemd_service "otrs" do
  description "OTRS Daemon"
  type "forking"
  user "otrs"
  group "otrs"
  exec_start "/opt/otrs/bin/otrs.Daemon.pl start"
  private_tmp true
  protect_system "strict"
  protect_home true
  read_write_paths ["/opt/znuny-#{version}/var", "/var/log/exim4", "/var/spool/exim4"]
end

service "otrs" do
  action [:enable, :start]
  subscribes :restart, "systemd_service[otrs]"
end

ssl_certificate site do
  domains [site] + site_aliases
  notifies :reload, "service[apache2]"
end

apache_site site do
  template "apache.erb"
  variables :aliases => site_aliases
end

template "/etc/cron.daily/otrs-backup" do
  source "backup.cron.erb"
  owner "root"
  group "root"
  mode "755"
end
