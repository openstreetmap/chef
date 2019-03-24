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
#     https://www.apache.org/licenses/LICENSE-2.0
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
include_recipe "memcached"
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
  php-mysql
  php-pear
  php-pgsql
  php-sqlite3
  pngcrush
  pngquant
  python
  python-argparse
  python-beautifulsoup
  python-cheetah
  python-dateutil
  python-magic
  python-psycopg2
  python-gdal
  g++
  gcc
  make
  autoconf
  automake
  libtool
  libfcgi-dev
  libxml2-dev
  libmemcached-dev
  libboost-regex-dev
  libboost-system-dev
  libboost-program-options-dev
  libboost-date-time-dev
  libboost-filesystem-dev
  libboost-locale-dev
  libpqxx-dev
  libcrypto++-dev
  libyajl-dev
  zlib1g-dev
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

service "php7.2-fpm" do
  action [:enable, :start]
end

template "/etc/php/7.2/fpm/pool.d/default.conf" do
  source "fpm-default.conf.erb"
  owner "root"
  group "root"
  mode 0o644
  notifies :reload, "service[php7.2-fpm]"
end

file "/etc/php/7.2/fpm/pool.d/www.conf" do
  action :delete
  notifies :reload, "service[php7.2-fpm]"
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

  template "/etc/php/7.2/fpm/pool.d/#{name}.conf" do
    source "fpm.conf.erb"
    owner "root"
    group "root"
    mode 0o644
    variables :user => name, :port => port
    notifies :reload, "service[php7.2-fpm]"
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

  ruby_version = node[:passenger][:ruby_version]

  systemd_service "rails-jobs@" do
    description "Rails job queue runner"
    type "simple"
    user "apis"
    working_directory "/srv/%i.apis.dev.openstreetmap.org/rails"
    exec_start "/usr/local/bin/bundle#{ruby_version} exec rake jobs:work"
    restart "on-failure"
    private_tmp true
    private_devices true
    protect_system "full"
    protect_home true
    no_new_privileges true
  end

  systemd_service "cgimap@" do
    description "OpenStreetMap API Server"
    type "forking"
    environment_file "/etc/default/cgimap-%i"
    user "apis"
    exec_start "/srv/%i.apis.dev.openstreetmap.org/cgimap/openstreetmap-cgimap --daemon --port $CGIMAP_PORT --instances 5"
    exec_reload "/bin/kill -HUP $MAINPID"
    private_tmp true
    private_devices true
    protect_system "full"
    protect_home true
    no_new_privileges true
    restart "on-failure"
  end

  cgimap_port = 9000

  node[:dev][:rails].each do |name, details|
    database_name = details[:database] || "apis_#{name}"
    site_name = "#{name}.apis.dev.openstreetmap.org"
    site_directory = "/srv/#{name}.apis.dev.openstreetmap.org"
    log_directory = "#{site_directory}/logs"
    rails_directory = "#{site_directory}/rails"
    cgimap_directory = "#{site_directory}/cgimap"
    gpx_directory = "#{site_directory}/gpx"

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

      directory site_directory do
        owner "apis"
        group "apis"
        mode 0o755
      end

      directory log_directory do
        owner "apis"
        group "apis"
        mode 0o755
      end

      directory gpx_directory do
        owner "apis"
        group "apis"
        mode 0o755
      end

      directory "#{gpx_directory}/traces" do
        owner "apis"
        group "apis"
        mode 0o755
      end

      directory "#{gpx_directory}/images" do
        owner "apis"
        group "apis"
        mode 0o755
      end

      rails_port site_name do
        ruby ruby_version
        directory rails_directory
        user "apis"
        group "apis"
        repository details[:repository]
        revision details[:revision]
        database_port node[:postgresql][:clusters][:"9.5/main"][:port]
        database_name database_name
        database_username "apis"
        gpx_dir gpx_directory
        log_path "#{log_directory}/rails.log"
        memcache_servers ["127.0.0.1"]
        csp_enforce true
        run_migrations true
        trace_use_job_queue true
      end

      template "#{rails_directory}/config/initializers/setup.rb" do
        source "rails.setup.rb.erb"
        owner "apis"
        group "apis"
        mode 0o644
        variables :site => site_name
        notifies :restart, "rails_port[#{site_name}]"
      end

      service "rails-jobs@#{name}" do
        action [:enable, :start]
        supports :restart => true
        subscribes :restart, "rails_port[#{site_name}]"
        subscribes :restart, "systemd_service[#{name}]"
        only_if "fgrep -q delayed_job #{rails_directory}/Gemfile.lock"
      end

      if details[:cgimap_repository]
        git cgimap_directory do
          action :sync
          repository details[:cgimap_repository]
          revision details[:cgimap_revision]
          user "apis"
          group "apis"
        end

        execute "#{cgimap_directory}/autogen.sh" do
          action :nothing
          command "./autogen.sh"
          cwd cgimap_directory
          user "apis"
          group "apis"
          subscribes :run, "git[#{cgimap_directory}]", :immediate
        end

        execute "#{cgimap_directory}/configure" do
          action :nothing
          command "./configure --with-fcgi=/usr --with-boost-libdir=/usr/lib/x86_64-linux-gnu --enable-yajl"
          cwd cgimap_directory
          user "apis"
          group "apis"
          subscribes :run, "execute[#{cgimap_directory}/autogen.sh]", :immediate
        end

        execute "#{cgimap_directory}/Makefile" do
          action :nothing
          command "make -j"
          cwd cgimap_directory
          user "apis"
          group "apis"
          subscribes :run, "execute[#{cgimap_directory}/configure]", :immediate
          notifies :restart, "service[cgimap@#{name}]"
        end

        template "/etc/default/cgimap-#{name}" do
          source "cgimap.environment.erb"
          owner "root"
          group "root"
          mode 0o640
          variables :cgimap_port => cgimap_port,
                    :database_port => node[:postgresql][:clusters][:"9.5/main"][:port],
                    :database_name => database_name,
                    :log_directory => log_directory
          notifies :restart, "service[cgimap@#{name}]"
        end

        service "cgimap@#{name}" do
          action [:start, :enable]
        end
      end

      ssl_certificate site_name do
        domains [site_name] + site_aliases
        notifies :reload, "service[apache2]"
      end

      apache_site site_name do
        template "apache.rails.erb"
        variables :application_name => name,
                  :aliases => site_aliases,
                  :secret_key_base => secret_key_base,
                  :cgimap_enabled => details.key?(:cgimap_repository),
                  :cgimap_port => cgimap_port
      end

      template "/etc/logrotate.d/apis-#{name}" do
        source "logrotate.apis.erb"
        owner "root"
        group "root"
        mode 0o644
        variables :name => name,
                  :log_directory => log_directory,
                  :rails_directory => rails_directory
      end

      cgimap_port += 1
    else
      file "/etc/logrotate.d/apis-#{name}" do
        action :delete
      end

      apache_site site_name do
        action [:delete]
      end

      service "cgimap@#{name}" do
        action [:stop, :disable]
      end

      file "/etc/default/cgimap-#{name}" do
        action :delete
      end

      directory site_directory do
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
