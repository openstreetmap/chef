#
# Cookbook Name:: otrs
# Recipe:: default
#
# Copyright 2012, OpenStreetMap Foundation
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

include_recipe "tools"
include_recipe "postgresql"
include_recipe "apache::ssl"

passwords = data_bag_item("otrs", "passwords")

package "libapache2-mod-perl2"
package "libapache2-reload-perl"

package "libgd-gd2-perl"
package "libgd-graph-perl"
package "libgd-text-perl"
package "libjson-xs-perl"
package "libmail-imapclient-perl"
package "libnet-ldap-perl"
package "libpdf-api2-perl"
package "libsoap-lite-perl"

apache_module "headers"

version = node[:otrs][:version]
user = node[:otrs][:user]
group = node[:otrs][:group]
database_cluster = node[:otrs][:database_cluster]
database_name = node[:otrs][:database_name]
database_user = node[:otrs][:database_user]
database_password = passwords[node[:otrs][:database_password]]
site = node[:otrs][:site]

remote_file "/tmp/otrs-#{version}.tar.bz2" do
  source "http://ftp.otrs.org/pub/otrs/otrs-#{version}.tar.bz2"
  not_if { File.exist?("/opt/otrs-#{version}") }
end

execute "untar-otrs-#{version}" do
  command "tar jxf /tmp/otrs-#{version}.tar.bz2"
  cwd "/opt"
  user "root"
  group "root"
  not_if { File.exist?("/opt/otrs-#{version}") }
end

config = edit_file "/opt/otrs-#{version}/Kernel/Config.pm.dist" do |line|
  line.gsub!(/^( *)\$Self->{Database} = 'otrs'/, "\\1$Self->{Database} = '#{database_name}'")
  line.gsub!(/^( *)\$Self->{DatabaseUser} = 'otrs'/, "\\1$Self->{DatabaseUser} = '#{database_user}'")
  line.gsub!(/^( *)\$Self->{DatabasePw} = 'some-pass'/, "\\1$Self->{DatabasePw} = '#{database_password}'")
  line.gsub!(/^( *)\$Self->{Database} = 'otrs'/, "\\1$Self->{Database} = '#{database_name}'")
  line.gsub!(/^( *\$Self->{DatabaseDSN} = "DBI:mysql:)/, "#\\1")
  line.gsub!(/^#( *\$Self->{DatabaseDSN} = "DBI:Pg:.*;host=)/, "\\1")

  line
end

file "/opt/otrs-#{version}/Kernel/Config.pm" do
  owner user
  group "www-data"
  mode 0664
  content config
end

file "/opt/otrs-#{version}/Kernel/Config/GenericAgent.pm" do
  owner user
  group "www-data"
  mode 0664
  content IO.read("/opt/otrs-#{version}/Kernel/Config/GenericAgent.pm.dist")
end

link "/opt/otrs" do
  to "/opt/otrs-#{version}"
end

execute "/opt/otrs/bin/otrs.SetPermissions.pl" do
  action :run
  command "/opt/otrs/bin/otrs.SetPermissions.pl --otrs-user=#{user} --web-user=www-data --otrs-group=www-data --web-group=www-data /opt/otrs-#{version}"
  user "root"
  group "root"
  not_if { File.stat("/opt/otrs/README").uid != Etc.getpwnam("otrs").uid }
end

execute "/opt/otrs/bin/otrs.RebuildConfig.pl" do
  action :run
  command "/opt/otrs/bin/otrs.RebuildConfig.pl"
  user "root"
  group "root"
  not_if { File.exist?("/opt/otrs/Kernel/Config/Files/ZZZAAuto.pm") }
end

if node[:postgresql][:clusters][database_cluster]
  postgresql_user database_user do
    cluster database_cluster
    password database_password
  end

  postgresql_database database_name do
    cluster database_cluster
    owner database_user
  end
end

execute "/opt/otrs/bin/Cron.sh" do
  action :nothing
  command "/opt/otrs/bin/Cron.sh restart"
  user "otrs"
  group "otrs"
end

Dir.glob("/opt/otrs/var/cron/*.dist") do |distname|
  name = distname.sub(".dist", "")

  file name do
    owner "otrs"
    group "www-data"
    mode 0664
    content IO.read(distname)
    notifies :run, "execute[/opt/otrs/bin/Cron.sh]"
  end
end

apache_site site do
  template "apache.erb"
end

template "/etc/sudoers.d/otrs" do
  source "sudoers.erb"
  owner "root"
  group "root"
  mode 0440
end

template "/etc/cron.daily/otrs-backup" do
  source "backup.cron.erb"
  owner "root"
  group "root"
  mode 0755
end
