#
# Cookbook:: osqa
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

include_recipe "accounts"
include_recipe "apache"
include_recipe "memcached"
include_recipe "python"
include_recipe "tools"

package "python-dev"
package "libmysqlclient-dev"
package "libpq-dev"

python_directory = "/opt/osqa-python"

python_virtualenv python_directory do
  interpreter "/usr/bin/python2"
end

python_package "Django" do
  python_virtualenv python_directory
  version "1.6.11"
end

python_package "Markdown" do
  python_virtualenv python_directory
  version "2.4"
end

python_package "python-memcached" do
  python_virtualenv python_directory
  version "1.53"
end

python_package "python-openid" do
  python_virtualenv python_directory
  version "2.2.5"
end

python_package "psycopg2" do
  python_virtualenv python_directory
  version "2.7.6.1"
end

python_package "South" do
  python_virtualenv python_directory
  version "0.7.6"
end

python_package "html5lib" do
  python_virtualenv python_directory
  version "0.999"
end

apache_module "rewrite"
apache_module "wsgi"

node[:osqa][:sites].each do |site|
  site_name = site[:name]
  site_aliases = site[:aliases] || []
  directory = site[:directory] || "/srv/#{site_name}"
  site_user = site[:user] || node[:osqa][:user]
  site_user = Etc.getpwuid(site_user).name if site_user.is_a?(Integer)
  site_group = site[:group] || node[:osqa][:group] || Etc.getpwnam(site_user).gid
  site_group = Etc.getgrgid(site_group).name if site_group.is_a?(Integer)
  database_name = site[:database_name] || node[:osqa][:database_name]
  database_user = site[:database_user] || node[:osqa][:database_user]
  database_password = site[:database_user] || node[:osqa][:database_password]
  backup_name = site[:backup]

  ssl_certificate site_name do
    domains [site_name] + site_aliases
    notifies :reload, "service[apache2]"
  end

  apache_site site_name do
    template "apache.erb"
    directory directory
    variables :user => site_user, :group => site_group, :aliases => site_aliases, :python_home => python_directory
  end

  directory directory do
    owner site_user
    group site_group
    mode "755"
  end

  execute "osqa-migrate" do
    action :nothing
    command "python manage.py migrate forum"
    cwd "#{directory}/osqa"
    user site_user
    group site_group
    notifies :reload, "service[apache2]"
  end

  git "#{directory}/osqa" do
    action :sync
    repository "https://git.openstreetmap.org/public/osqa.git"
    revision "live"
    depth 1
    user site_user
    group site_group
    notifies :run, "execute[osqa-migrate]"
  end

  directory "#{directory}/upfiles" do
    user site_user
    group site_group
    mode "755"
  end

  template "#{directory}/osqa/osqa.wsgi" do
    source "osqa.wsgi.erb"
    owner site_user
    group site_group
    mode "644"
    variables :directory => directory
    notifies :reload, "service[apache2]"
  end

  settings = edit_file "#{directory}/osqa/settings_local.py.dist" do |line|
    line.gsub!(/^( *)'ENGINE': '.*',/, "\\1'ENGINE': 'django.db.backends.postgresql_psycopg2',")
    line.gsub!(/^( *)'NAME': '.*',/, "\\1'NAME': '#{database_name}',")
    line.gsub!(/^( *)'USER': '.*',/, "\\1'USER': '#{database_user}',")
    line.gsub!(/^( *)'PASSWORD': '.*',/, "\\1'PASSWORD': '#{database_password}',")
    line.gsub!(/^ALLOWED_HOSTS = .*/, "ALLOWED_HOSTS = ('help.openstreetmap.org',)")
    line.gsub!(/^CACHE_BACKEND = .*/, "CACHE_BACKEND = 'memcached://127.0.0.1:11211/'")
    line.gsub!(%r{^APP_URL = 'http://'}, "APP_URL = 'https://#{site_name}'")
    line.gsub!(%r{^TIME_ZONE = 'America/New_York'}, "TIME_ZONE = 'Europe/London'")
    line.gsub!(/^DISABLED_MODULES = \[([^\]]+)\]/, "DISABLED_MODULES = [\\1, 'localauth', 'facebookauth', 'oauthauth']")

    line
  end

  file "#{directory}/osqa/settings_local.py" do
    owner site_user
    group site_group
    mode "644"
    content settings
    notifies :reload, "service[apache2]"
  end

  template "/etc/cron.daily/#{backup_name}-backup" do
    source "backup.cron.erb"
    owner "root"
    group "root"
    mode "755"
    variables :name => backup_name, :directory => directory, :user => site_user, :database => database_name
  end
end
