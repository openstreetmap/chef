#
# Cookbook Name:: web
# Definition:: rails_port
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

require "yaml"

define :rails_port, :action => [:create, :enable] do
  name = params[:name]
  ruby_version = params[:ruby] || "1.9.1"
  rails_directory = params[:directory] || "/srv/#{name}"
  rails_user = params[:user]
  rails_group = params[:group]
  rails_repository = params[:repository] || "git://git.openstreetmap.org/rails.git"
  rails_revision = params[:revision] || "live"
  run_migrations = params[:run_migrations] || false
  status = params[:status] || "online"

  database_params = {
    :host => params[:database_host],
    :port => params[:database_port],
    :name => params[:database_name],
    :username => params[:database_username],
    :password => params[:database_password]
  }

  package "ruby#{ruby_version}"
  package "ruby#{ruby_version}-dev"
  package "rubygems#{ruby_version}" if ruby_version.to_f < 1.9
  package "irb#{ruby_version}" if ruby_version.to_f < 1.9
  package "imagemagick"
  package "nodejs"

  package "g++"
  package "pkg-config"
  package "libpq-dev"
  package "libsasl2-dev"
  package "libxml2-dev"
  package "libxslt1-dev"
  package "libmemcached-dev"

  gem_package "bundler#{ruby_version}" do
    package_name "bundler"
    version "1.3.5"
    gem_binary "gem#{ruby_version}"
    options "--format-executable"
  end

  file "/usr/lib/ruby/1.8/rack.rb" do
    action :delete
  end

  directory "/usr/lib/ruby/1.8/rack" do
    action :delete
    recursive true
  end

  execute rails_directory do
    action :nothing
    command "passenger-config restart-app #{rails_directory}"
    user "root"
    group "root"
    only_if { File.exist?("/usr/bin/passenger-config") }
  end

  file "#{rails_directory}/public/export/embed.html" do
    action :nothing
  end

  execute "#{rails_directory}/public/assets" do
    action :nothing
    command "bundle#{ruby_version} exec rake#{ruby_version} assets:precompile"
    environment "RAILS_ENV" => "production"
    cwd rails_directory
    user rails_user
    group rails_group
    notifies :delete, "file[#{rails_directory}/public/export/embed.html]"
    notifies :run, "execute[#{rails_directory}]"
  end

  execute "#{rails_directory}/db/migrate" do
    action :nothing
    command "bundle#{ruby_version} exec rake#{ruby_version} db:migrate"
    cwd rails_directory
    user rails_user
    group rails_group
    notifies :run, "execute[#{rails_directory}/public/assets]"
  end

  execute "#{rails_directory}/Gemfile" do
    action :nothing
    command "bundle#{ruby_version} install"
    cwd rails_directory
    user "root"
    group "root"
    environment "NOKOGIRI_USE_SYSTEM_LIBRARIES" => "yes"
    if run_migrations
      notifies :run, "execute[#{rails_directory}/db/migrate]"
    else
      notifies :run, "execute[#{rails_directory}/public/assets]"
    end
    subscribes :run, "gem_package[bundler#{ruby_version}]"
  end

  directory rails_directory do
    owner rails_user
    group rails_group
    mode 02775
  end

  git rails_directory do
    action :sync
    repository rails_repository
    revision rails_revision
    user rails_user
    group rails_group
    notifies :run, "execute[#{rails_directory}/Gemfile]"
  end

  directory "#{rails_directory}/tmp" do
    owner rails_user
    group rails_group
  end

  file "#{rails_directory}/config/environment.rb" do
    owner rails_user
    group rails_group
  end

  template "#{rails_directory}/config/database.yml" do
    cookbook "web"
    source "database.yml.erb"
    owner rails_user
    group rails_group
    mode 0664
    variables database_params
    notifies :run, "execute[#{rails_directory}]"
  end

  application_yml = edit_file "#{rails_directory}/config/example.application.yml" do |line|
    line.gsub!(/^( *)server_url:.*$/, "\\1server_url: \"#{name}\"")

    if params[:email_from]
      line.gsub!(/^( *)email_from:.*$/, "\\1email_from: \"#{params[:email_from]}\"")
    end

    line.gsub!(/^( *)status:.*$/, "\\1status: :#{status}")

    if params[:messages_domain]
      line.gsub!(/^( *)#messages_domain:.*$/, "\\1messages_domain: \"#{params[:messages_domain]}\"")
    end

    line.gsub!(/^( *)#geonames_username:.*$/, "\\1geonames_username: \"openstreetmap\"")

    if params[:quova_username]
      line.gsub!(/^( *)#quova_username:.*$/, "\\1quova_username: \"#{params[:quova_username]}\"")
      line.gsub!(/^( *)#quova_password:.*$/, "\\1quova_password: \"#{params[:quova_password]}\"")
    end

    if params[:gpx_dir]
      line.gsub!(/^( *)gpx_trace_dir:.*$/, "\\1gpx_trace_dir: \"#{params[:gpx_dir]}/traces\"")
      line.gsub!(/^( *)gpx_image_dir:.*$/, "\\1gpx_image_dir: \"#{params[:gpx_dir]}/images\"")
    end

    if params[:attachments_dir]
      line.gsub!(/^( *)attachments_dir:.*$/, "\\1attachments_dir: \"#{params[:attachments_dir]}\"")
    end

    if params[:log_path]
      line.gsub!(/^( *)#log_path:.*$/, "\\1log_path: \"#{params[:log_path]}\"")
    end

    if params[:memcache_servers]
      line.gsub!(/^( *)#memcache_servers:.*$/, "\\1memcache_servers: [ \"#{params[:memcache_servers].join("\", \"")}\" ]")
    end

    if params[:potlatch2_key]
      line.gsub!(/^( *)#potlatch2_key:.*$/, "\\1potlatch2_key: \"#{params[:potlatch2_key]}\"")
    end

    if params[:id_key]
      line.gsub!(/^( *)#id_key:.*$/, "\\1id_key: \"#{params[:id_key]}\"")
    end

    if params[:oauth_key]
      line.gsub!(/^( *)#oauth_key:.*$/, "\\1oauth_key: \"#{params[:oauth_key]}\"")
    end

    if params[:nominatim_url]
      line.gsub!(/^( *)nominatim_url:.*$/, "\\1nominatim_url: \"#{params[:nominatim_url]}\"")
    end

    line.gsub!(/^( *)require_terms_seen:.*$/, "\\1require_terms_seen: true")
    line.gsub!(/^( *)require_terms_agreed:.*$/, "\\1require_terms_agreed: true")

    line
  end

  file "#{rails_directory}/config/application.yml" do
    owner rails_user
    group rails_group
    mode 0664
    content application_yml
    notifies :run, "execute[#{rails_directory}]"
  end

  if params[:piwik_configuration]
    file "#{rails_directory}/config/piwik.yml" do
      owner rails_user
      group rails_group
      mode 0664
      content YAML.dump(params[:piwik_configuration])
      notifies :run, "execute[#{rails_directory}/public/assets]"
    end
  else
    file "#{rails_directory}/config/piwik.yml" do
      action :delete
      notifies :run, "execute[#{rails_directory}/public/assets]"
    end
  end

  execute "#{rails_directory}/lib/quad_tile/extconf.rb" do
    command "ruby extconf.rb"
    cwd "#{rails_directory}/lib/quad_tile"
    user rails_user
    group rails_group
    not_if { File.exist?("#{rails_directory}/lib/quad_tile/Makefile") && File.mtime("#{rails_directory}/lib/quad_tile/Makefile") >= File.mtime("#{rails_directory}/lib/quad_tile/extconf.rb") }
  end

  execute "#{rails_directory}/lib/quad_tile/Makefile" do
    command "make"
    cwd "#{rails_directory}/lib/quad_tile"
    user rails_user
    group rails_group
    not_if do
      File.exist?("#{rails_directory}/lib/quad_tile/quad_tile_so.so") &&
        File.mtime("#{rails_directory}/lib/quad_tile/quad_tile_so.so") >= File.mtime("#{rails_directory}/lib/quad_tile/Makefile") &&
        File.mtime("#{rails_directory}/lib/quad_tile/quad_tile_so.so") >= File.mtime("#{rails_directory}/lib/quad_tile/quad_tile.c") &&
        File.mtime("#{rails_directory}/lib/quad_tile/quad_tile_so.so") >= File.mtime("#{rails_directory}/lib/quad_tile/quad_tile.h")
    end
    notifies :run, "execute[#{rails_directory}]"
  end

  template "/etc/cron.daily/rails-#{name}" do
    cookbook "web"
    source "rails.cron.erb"
    owner "root"
    group "root"
    mode 0755
    variables :directory => rails_directory
  end
end
