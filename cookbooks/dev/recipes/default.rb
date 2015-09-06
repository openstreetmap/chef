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
include_recipe "postgresql"

package "php-apc"
package "php-db"
package "php-cgiwrap"
package "php-pear"

package "php5-cgi"
package "php5-cli"
package "php5-curl"
package "php5-fpm"
package "php5-imagick"
package "php5-mcrypt"
package "php5-mysql"
package "php5-pgsql"
package "php5-sqlite"

package "pngcrush"
package "pngquant"

package "python"
package "python-argparse"
package "python-beautifulsoup"
package "python-cheetah"
package "python-dateutil"
package "python-magic"
package "python-psycopg2"
package "python-gdal"

easy_install_package "geojson"

apache_module "env"
apache_module "expires"
apache_module "proxy"
apache_module "proxy_fcgi"
apache_module "rewrite"
apache_module "wsgi"

gem_package "sqlite3"

gem_package "rails" do
  version "3.0.9"
end

service "php5-fpm" do
  provider Chef::Provider::Service::Upstart
  action [:enable, :start]
  supports :status => true, :restart => true, :reload => true
end

template "/etc/php5/fpm/pool.d/default.conf" do
  source "fpm-default.conf.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :reload, "service[php5-fpm]"
end

file "/etc/php5/fpm/pool.d/www.conf" do
  action :delete
  notifies :reload, "service[php5-fpm]"
end

package "phppgadmin"

template "/etc/phppgadmin/config.inc.php" do
  source "phppgadmin.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

file "/etc/apache2/conf.d/phppgadmin" do
  action :delete
end

apache_site "phppgadmin.dev.openstreetmap.org" do
  template "apache.phppgadmin.erb"
end

search(:accounts, "*:*").each do |account|
  name = account["id"]
  details = node[:accounts][:users][name] || {}

  next unless %w(user administrator).include?(details[:status])

  user_home = details[:home] || account["home"] || "#{node[:accounts][:home]}/#{name}"

  next unless File.directory?("#{user_home}/public_html")

  port = 7000 + account["uid"].to_i

  template "/etc/php5/fpm/pool.d/#{name}.conf" do
    source "fpm.conf.erb"
    owner "root"
    group "root"
    mode 0644
    variables :user => name, :port => port
    notifies :reload, "service[php5-fpm]"
  end

  apache_site "#{name}.dev.openstreetmap.org" do
    template "apache.user.erb"
    directory "#{user_home}/public_html"
    variables :user => name, :port => port
  end
end

if node[:postgresql][:clusters][:"9.1/main"]
  postgresql_user "apis" do
    cluster "9.3/main"
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
        cluster "9.3/main"
        owner "apis"
      end

      postgresql_extension "#{database_name}_btree_gist" do
        cluster "9.3/main"
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
        database_port node[:postgresql][:clusters][:"9.3/main"][:port]
        database_name database_name
        database_username "apis"
        run_migrations true
      end

      template "#{rails_directory}/config/initializers/setup.rb" do
        source "rails.setup.rb.erb"
        owner "apis"
        group "apis"
        mode 0644
        variables :site => site_name
        notifies :run, "execute[#{rails_directory}]"
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

      file "/etc/cron.daily/rails-#{name}" do
        action :delete
      end

      postgresql_database database_name do
        action :drop
        cluster "9.3/main"
      end

      node.normal[:dev][:rails].delete(name)
    end
  end

  directory "/srv/apis.dev.openstreetmap.org" do
    owner "apis"
    group "apis"
    mode 0755
  end

  template "/srv/apis.dev.openstreetmap.org/index.html" do
    source "apis.html.erb"
    owner "apis"
    group "apis"
    mode 0644
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
