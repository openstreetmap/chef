#
# Cookbook:: dev
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

require "yaml"
require "securerandom"

include_recipe "apache"
include_recipe "passenger"
include_recipe "geoipupdate"
include_recipe "git"
include_recipe "memcached"
include_recipe "munin"
include_recipe "mysql"
include_recipe "nodejs"
include_recipe "php::fpm"
include_recipe "postgresql"
include_recipe "python"

package %w[
  php-cgi
  php-cli
  php-curl
  php-db
  php-imagick
  php-mysql
  php-pear
  php-pgsql
  php-sqlite3
  pngcrush
  pngquant
  python3
  python3-bs4
  python3-cheetah
  python3-dateutil
  python3-magic
  python3-psycopg2
  python3-gdal
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

python_package "geojson" do
  python_version "3"
end

apache_module "env"
apache_module "expires"
apache_module "headers"
apache_module "proxy"
apache_module "proxy_fcgi"
apache_module "rewrite"
apache_module "suexec"
apache_module "userdir"

apache_module "wsgi" do
  package "libapache2-mod-wsgi-py3"
end

package "apache2-suexec-pristine"

php_fpm "default" do
  pm_max_children 10
  pm_start_servers 4
  pm_min_spare_servers 2
  pm_max_spare_servers 6
end

php_fpm "www" do
  action :delete
end

directory "/srv/dev.openstreetmap.org" do
  owner "root"
  group "root"
  mode "755"
end

template "/srv/dev.openstreetmap.org/index.html" do
  source "dev.html.erb"
  owner "root"
  group "root"
  mode "644"
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
  mode "644"
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

  php_fpm name do
    user name
    group name
    pm_max_children 10
    pm_start_servers 4
    pm_min_spare_servers 2
    pm_max_spare_servers 6
    pm_max_requests 10000
    request_terminate_timeout 1800
    environment "HOSTNAME" => "$HOSTNAME",
                "PATH" => "/usr/local/bin:/usr/bin:/bin",
                "TMP" => "/tmp",
                "TMPDIR" => "/tmp",
                "TEMP" => "/tmp"
    php_values "max_execution_time" => "300",
               "memory_limit" => "128M",
               "post_max_size" => "32M",
               "upload_max_filesize" => "32M"
    php_admin_values "sendmail_path" => "/usr/sbin/sendmail -t -i -f #{name}@errol.openstreetmap.org",
                     "open_basedir" => "/home/#{name}/:/tmp/:/usr/share/php/"
    php_flags "display_errors" => "on"
  end

  ssl_certificate "#{name}.dev.openstreetmap.org" do
    domains ["#{name}.dev.openstreetmap.org", "#{name}.dev.osm.org"]
    notifies :reload, "service[apache2]"
  end

  apache_site "#{name}.dev.openstreetmap.org" do
    template "apache.user.erb"
    directory "#{user_home}/public_html"
    variables :user => name
  end

  template "/etc/sudoers.d/#{name}" do
    source "sudoers.user.erb"
    owner "root"
    group "root"
    mode "440"
    variables :user => name
  end
end

if node[:postgresql][:clusters][:"12/main"]
  postgresql_user "apis" do
    cluster "12/main"
  end

  template "/usr/local/bin/cleanup-rails-assets" do
    cookbook "web"
    source "cleanup-assets.erb"
    owner "root"
    group "root"
    mode "755"
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
      secret_key_base = persistent_token("dev", "rails", name, "secret_key_base")

      postgresql_database database_name do
        cluster "12/main"
        owner "apis"
      end

      postgresql_extension "#{database_name}_btree_gist" do
        cluster "12/main"
        database database_name
        extension "btree_gist"
      end

      directory site_directory do
        owner "apis"
        group "apis"
        mode "755"
      end

      directory log_directory do
        owner "apis"
        group "apis"
        mode "755"
      end

      directory gpx_directory do
        owner "apis"
        group "apis"
        mode "755"
      end

      directory "#{gpx_directory}/traces" do
        owner "apis"
        group "apis"
        mode "755"
      end

      directory "#{gpx_directory}/images" do
        owner "apis"
        group "apis"
        mode "755"
      end

      rails_port site_name do
        ruby ruby_version
        directory rails_directory
        user "apis"
        group "apis"
        repository details[:repository]
        revision details[:revision]
        database_port node[:postgresql][:clusters][:"12/main"][:port]
        database_name database_name
        database_username "apis"
        email_from "OpenStreetMap <web@noreply.openstreetmap.org>"
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
        mode "644"
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
          mode "640"
          variables :cgimap_port => cgimap_port,
                    :database_port => node[:postgresql][:clusters][:"12/main"][:port],
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
        mode "644"
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
        cluster "12/main"
      end
    end
  end

  directory "/srv/apis.dev.openstreetmap.org" do
    owner "apis"
    group "apis"
    mode "755"
  end

  template "/srv/apis.dev.openstreetmap.org/index.html" do
    source "apis.html.erb"
    owner "apis"
    group "apis"
    mode "644"
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
  mode "755"
end

remote_directory "/srv/ooc.openstreetmap.org/html" do
  source "ooc"
  owner "root"
  group "root"
  mode "755"
  files_owner "root"
  files_group "root"
  files_mode "644"
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
