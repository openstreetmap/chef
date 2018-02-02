#
# Cookbook Name:: dev
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

require "yaml"
require "securerandom"

include_recipe "apache"
include_recipe "passenger"
include_recipe "git"
include_recipe "mysql"
include_recipe "nodejs"
include_recipe "postgresql"
include_recipe "python"

package %w[
  php
  php-cgi
  php-cli
  php-curl
  php-db
  php-fpm
  php-imagick
  php-mcrypt
  php-mysql
  php-pear
  php-pgsql
  php-sqlite3
]

package %w[
  pngcrush
  pngquant
]

package %w[
  python
  python-argparse
  python-beautifulsoup
  python-cheetah
  python-dateutil
  python-magic
  python-psycopg2
  python-gdal
]

nodejs_package "svgo"

python_package "geojson"

apache_module "env"
apache_module "expires"
apache_module "headers"
apache_module "proxy"
apache_module "proxy_fcgi"
apache_module "rewrite"
apache_module "suexec"
apache_module "userdir"
apache_module "wsgi"

package "apache2-suexec-pristine"

gem_package "sqlite3"

gem_package "rails" do
  version "3.0.9"
end

service "php7.0-fpm" do
  action [:enable, :start]
end

template "/etc/php/7.0/fpm/pool.d/default.conf" do
  source "fpm-default.conf.erb"
  owner "root"
  group "root"
  mode 0o644
  notifies :reload, "service[php7.0-fpm]"
end

file "/etc/php/7.0/fpm/pool.d/www.conf" do
  action :delete
  notifies :reload, "service[php7.0-fpm]"
end

directory "/srv/dev.openstreetmap.org" do
  owner "root"
  group "root"
  mode 0o755
end

template "/srv/dev.openstreetmap.org/index.html" do
  source "dev.html.erb"
  owner "root"
  group "root"
  mode 0o644
end

ssl_certificate "dev.openstreetmap.org" do
  domains "dev.openstreetmap.org"
  notifies :reload, "service[apache2]"
end

apache_site "dev.openstreetmap.org" do
  template "apache.dev.erb"
end

package "phppgadmin"

template "/etc/phppgadmin/config.inc.php" do
  source "phppgadmin.conf.erb"
  owner "root"
  group "root"
  mode 0o644
end

file "/etc/apache2/conf.d/phppgadmin" do
  action :delete
end

ssl_certificate "phppgadmin.dev.openstreetmap.org" do
  domains "phppgadmin.dev.openstreetmap.org"
  notifies :reload, "service[apache2]"
end

apache_site "phppgadmin.dev.openstreetmap.org" do
  template "apache.phppgadmin.erb"
end

search(:accounts, "*:*").each do |account|
  name = account["id"]
  details = node[:accounts][:users][name] || {}

  next unless %w[user administrator].include?(details[:status])

  user_home = details[:home] || account["home"] || "#{node[:accounts][:home]}/#{name}"

  next unless File.directory?("#{user_home}/public_html")

  port = 7000 + account["uid"].to_i

  template "/etc/php/7.0/fpm/pool.d/#{name}.conf" do
    source "fpm.conf.erb"
    owner "root"
    group "root"
    mode 0o644
    variables :user => name, :port => port
    notifies :reload, "service[php7.0-fpm]"
  end

  ssl_certificate "#{name}.dev.openstreetmap.org" do
    domains ["#{name}.dev.openstreetmap.org", "#{name}.dev.osm.org"]
    notifies :reload, "service[apache2]"
  end

  apache_site "#{name}.dev.openstreetmap.org" do
    template "apache.user.erb"
    directory "#{user_home}/public_html"
    variables :user => name, :port => port
  end

  template "/etc/sudoers.d/#{name}" do
    source "sudoers.user.erb"
    owner "root"
    group "root"
    mode 0o440
    variables :user => name
  end
end

if node[:postgresql][:clusters][:"9.5/main"]
  postgresql_user "apis" do
    cluster "9.5/main"
  end

  template "/usr/local/bin/cleanup-rails-assets" do
    cookbook "web"
    source "cleanup-assets.erb"
    owner "root"
    group "root"
    mode 0o755
  end

  node[:dev][:rails].each do |name, details|
    database_name = details[:database] || "apis_#{name}"
    site_name = "#{name}.apis.dev.openstreetmap.org"
    rails_directory = "/srv/#{name}.apis.dev.openstreetmap.org"

    if details[:repository]
      site_aliases = details[:aliases] || []
      secret_key_base = details[:secret_key_base] || SecureRandom.base64(96)

      node.normal[:dev][:rails][name][:secret_key_base] = secret_key_base

      postgresql_database database_name do
        cluster "9.5/main"
        owner "apis"
      end

      postgresql_extension "#{database_name}_btree_gist" do
        cluster "9.5/main"
        database database_name
        extension "btree_gist"
      end

      rails_port site_name do
        ruby node[:passenger][:ruby_version]
        directory rails_directory
        user "apis"
        group "apis"
        repository details[:repository]
        revision details[:revision]
        database_port node[:postgresql][:clusters][:"9.5/main"][:port]
        database_name database_name
        database_username "apis"
        run_migrations true
      end

      template "#{rails_directory}/config/initializers/setup.rb" do
        source "rails.setup.rb.erb"
        owner "apis"
        group "apis"
        mode 0o644
        variables :site => site_name
        notifies :restart, "rails_port[#{site_name}]"
      end

      ssl_certificate site_name do
        domains [site_name] + site_aliases
        notifies :reload, "service[apache2]"
      end

      apache_site site_name do
        template "apache.rails.erb"
        variables :name => site_name, :aliases => site_aliases, :secret_key_base => secret_key_base
      end
    else
      apache_site site_name do
        action [:delete]
      end

      directory rails_directory do
        action :delete
        recursive true
      end

      file "/etc/cron.daily/rails-#{site_name.tr('.', '-')}" do
        action :delete
      end

      postgresql_database database_name do
        action :drop
        cluster "9.5/main"
      end

      node.normal[:dev][:rails].delete(name)
    end
  end

  directory "/srv/apis.dev.openstreetmap.org" do
    owner "apis"
    group "apis"
    mode 0o755
  end

  template "/srv/apis.dev.openstreetmap.org/index.html" do
    source "apis.html.erb"
    owner "apis"
    group "apis"
    mode 0o644
  end

  ssl_certificate "apis.dev.openstreetmap.org" do
    domains "apis.dev.openstreetmap.org"
    notifies :reload, "service[apache2]"
  end

  apache_site "apis.dev.openstreetmap.org" do
    template "apache.apis.erb"
  end

  node[:postgresql][:clusters].each_key do |name|
    postgresql_munin name do
      cluster name
      database "ALL"
    end
  end
end

directory "/srv/ooc.openstreetmap.org" do
  owner "root"
  group "root"
  mode 0o755
end

remote_directory "/srv/ooc.openstreetmap.org/html" do
  source "ooc"
  owner "root"
  group "root"
  mode 0o755
  files_owner "root"
  files_group "root"
  files_mode 0o644
end

ssl_certificate "ooc.openstreetmap.org" do
  domains ["ooc.openstreetmap.org",
           "a.ooc.openstreetmap.org",
           "b.ooc.openstreetmap.org",
           "c.ooc.openstreetmap.org"]
  notifies :reload, "service[apache2]"
end

apache_site "ooc.openstreetmap.org" do
  template "apache.ooc.erb"
end
