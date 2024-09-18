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

include_recipe "accounts"
include_recipe "apache"
include_recipe "passenger"
include_recipe "geoipupdate"
include_recipe "git"
include_recipe "memcached"
include_recipe "mysql"
include_recipe "nodejs"
include_recipe "php::fpm"
include_recipe "podman"
include_recipe "postgresql"
include_recipe "python"
include_recipe "ruby"

package %w[
  ant
  apache2-dev
  aria2
  at
  autoconf
  automake
  awscli
  cmake
  composer
  curl
  default-jdk-headless
  default-jre-headless
  eatmydata
  fonts-dejavu
  fonts-dejavu-core
  fonts-dejavu-extra
  fonts-droid-fallback
  fonts-liberation
  fonts-noto-mono
  g++
  gcc
  gdal-bin
  gfortran
  gnuplot-nox
  golang
  graphviz
  irssi
  jq
  libargon2-dev
  libboost-date-time-dev
  libboost-dev
  libboost-filesystem-dev
  libboost-locale-dev
  libboost-program-options-dev
  libboost-regex-dev
  libboost-system-dev
  libbrotli-dev
  libbytes-random-secure-perl
  libcairo2-dev
  libcrypto++-dev
  libcurl4-openssl-dev
  libfcgi-dev
  libfmt-dev
  libglib2.0-dev
  libiniparser-dev
  libjson-xs-perl
  libmapnik-dev
  libmemcached-dev
  libpqxx-dev
  libtool
  libxml-twig-perl
  libxml2-dev
  libyajl-dev
  lua-any
  luajit
  lz4
  lzip
  lzop
  mailutils
  make
  nano
  ncftp
  netcat-openbsd
  osm2pgsql
  osmium-tool
  osmosis
  pandoc
  pandoc
  pbzip2
  php-apcu
  php-cgi
  php-cli
  php-curl
  php-db
  php-gd
  php-igbinary
  php-imagick
  php-intl
  php-mbstring
  php-memcache
  php-mysql
  php-pear
  php-pgsql
  php-sqlite3
  php-xml
  pigz
  pngcrush
  pngquant
  proj-bin
  pyosmium
  python-is-python3
  python3
  python3-brotli
  python3-bs4
  python3-cheetah
  python3-dateutil
  python3-dev
  python3-dotenv
  python3-gdal
  python3-geojson
  python3-lxml
  python3-lz4
  python3-magic
  python3-pil
  python3-psycopg2
  python3-pyproj
  python3-venv
  r-base
  redis
  tmux
  unrar
  unzip
  whois
  zip
  zlib1g-dev
]

# Add uk_os_OSTN15_NTv2_OSGBtoETRS.tif used for reprojecting OS data
execute "uk_os_OSTN15_NTv2_OSGBtoETRS.tif" do
  command "projsync --file uk_os_OSTN15_NTv2_OSGBtoETRS.tif --system-directory"
  not_if { ::File.exist?("/usr/share/proj/uk_os_OSTN15_NTv2_OSGBtoETRS.tif") }
end

nodejs_package "svgo"

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
    php_admin_values "sendmail_path" => "/usr/sbin/sendmail -t -i -f #{name}@dev.openstreetmap.org",
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

node[:postgresql][:versions].each do |version|
  package "postgresql-#{version}-postgis-3"
end

if node[:postgresql][:clusters][:"15/main"]
  postgresql_user "apis" do
    cluster "15/main"
  end

  template "/usr/local/bin/cleanup-rails-assets" do
    cookbook "web"
    source "cleanup-assets.erb"
    owner "root"
    group "root"
    mode "755"
  end

  systemd_service "rails-jobs@" do
    description "Rails job queue runner"
    type "simple"
    environment_file "/etc/default/rails-%i"
    user "apis"
    working_directory "/srv/%i.apis.dev.openstreetmap.org/rails"
    exec_start "#{node[:ruby][:bundle]} exec rails jobs:work"
    restart "on-failure"
    nice 10
    sandbox :enable_network => true
    restrict_address_families "AF_UNIX"
    memory_deny_write_execute false
    read_write_paths [
      "/srv/%i.apis.dev.openstreetmap.org/logs",
      "/srv/%i.apis.dev.openstreetmap.org/rails/storage"
    ]
  end

  systemd_service "cgimap@" do
    description "OpenStreetMap API Server"
    type "forking"
    environment_file "/etc/default/cgimap-%i"
    user "apis"
    group "www-data"
    umask "0002"
    exec_start "/srv/%i.apis.dev.openstreetmap.org/cgimap/build/openstreetmap-cgimap --daemon --instances 5"
    exec_reload "/bin/kill -HUP $MAINPID"
    runtime_directory "cgimap-%i"
    sandbox :enable_network => true
    restrict_address_families "AF_UNIX"
    read_write_paths ["/srv/%i.apis.dev.openstreetmap.org/logs", "/srv/%i.apis.dev.openstreetmap.org/rails/tmp"]
    restart "on-failure"
  end

  Dir.glob("/srv/*.apis.dev.openstreetmap.org").each do |dir|
    node.default_unless[:dev][:rails][File.basename(dir).split(".").first] = {}
  end

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
        cluster "15/main"
        owner "apis"
      end

      postgresql_extension "#{database_name}_btree_gist" do
        cluster "15/main"
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

      openssl_rsa_private_key "#{site_directory}/doorkeeper.key" do
        owner "root"
        group "root"
        mode "0400"
      end

      rails_port site_name do
        directory rails_directory
        user "apis"
        group "apis"
        repository details[:repository]
        revision details[:revision]
        database_port node[:postgresql][:clusters][:"15/main"][:port]
        database_name database_name
        database_username "apis"
        email_from "OpenStreetMap <web@noreply.openstreetmap.org>"
        gpx_dir gpx_directory
        log_path "#{log_directory}/rails.log"
        memcache_servers ["127.0.0.1"]
        csp_enforce true
        run_migrations true
        trace_use_job_queue true
        doorkeeper_signing_key lazy { File.read("#{site_directory}/doorkeeper.key") }
      end

      template "#{rails_directory}/config/initializers/setup.rb" do
        source "rails.setup.rb.erb"
        owner "apis"
        group "apis"
        mode "644"
        variables :site => site_name
        notifies :restart, "rails_port[#{site_name}]"
      end

      template "/etc/default/rails-#{name}" do
        source "rails.environment.erb"
        owner "root"
        group "root"
        mode "0600"
        variables :secret_key_base => secret_key_base
      end

      service "rails-jobs@#{name}" do
        action [:enable, :start]
        supports :restart => true
        subscribes :restart, "rails_port[#{site_name}]"
        subscribes :restart, "systemd_service[rails-jobs@]"
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

        directory "#{cgimap_directory}/build" do
          user "apis"
          group "apis"
          mode "0755"
        end

        execute "#{cgimap_directory}/CMakeLists.txt" do
          action :nothing
          command "cmake .."
          cwd "#{cgimap_directory}/build"
          user "apis"
          group "apis"
          subscribes :run, "git[#{cgimap_directory}]", :immediately
        end

        execute "#{cgimap_directory}/build/Makefile" do
          action :nothing
          command "make -j"
          cwd "#{cgimap_directory}/build"
          user "apis"
          group "apis"
          subscribes :run, "execute[#{cgimap_directory}/CMakeLists.txt]", :immediately
        end

        template "/etc/default/cgimap-#{name}" do
          source "cgimap.environment.erb"
          owner "root"
          group "root"
          mode "640"
          variables :cgimap_socket => "/run/cgimap-#{name}/socket",
                    :database_port => node[:postgresql][:clusters][:"15/main"][:port],
                    :database_name => database_name,
                    :log_directory => log_directory,
                    :options => details[:cgimap_options]
        end

        service "cgimap@#{name}" do
          action [:start, :enable]
          subscribes :restart, "execute[#{cgimap_directory}/build/Makefile]"
          subscribes :restart, "template[/etc/default/cgimap-#{name}]"
          subscribes :restart, "systemd_service[cgimap@]"
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
                  :cgimap_socket => "/run/cgimap-#{name}/socket"
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

      service "rails-jobs@#{name}" do
        action [:stop, :disable]
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
        cluster "15/main"
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

directory "/etc/systemd/system/user-.slice.d" do
  owner "root"
  group "root"
  mode "0755"
end

template "/etc/systemd/system/user-.slice.d/99-chef.conf" do
  source "user-slice.conf.erb"
  owner "root"
  group "root"
  mode "0644"
end
