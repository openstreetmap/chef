# Cookbook:: wordpress
# Resource:: wordpress_site
#
# Copyright:: 2015, OpenStreetMap Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require "securerandom"

default_action :create

property :site, :kind_of => String, :name_property => true
property :aliases, :kind_of => [String, Array]
property :directory, :kind_of => String
property :version, :kind_of => String
property :database_name, :kind_of => String, :required => true
property :database_user, :kind_of => String, :required => [:create]
property :database_password, :kind_of => String, :required => [:create]
property :database_prefix, :kind_of => String, :default => "wp_"
property :urls, :kind_of => Hash, :default => {}
property :fpm_max_children, :kind_of => Integer, :default => 5
property :fpm_start_servers, :kind_of => Integer, :default => 2
property :fpm_min_spare_servers, :kind_of => Integer, :default => 1
property :fpm_max_spare_servers, :kind_of => Integer, :default => 3
property :fpm_request_terminate_timeout, :kind_of => Integer, :default => 300
property :fpm_prometheus_port, :kind_of => Integer
property :reload_apache, :kind_of => [TrueClass, FalseClass], :default => true

action :create do
  version = new_resource.version || Chef::Wordpress.current_version

  node.default[:wordpress][:sites][new_resource.site] = {
    :directory => site_directory
  }

  auth_key = persistent_token("wordpress", new_resource.site, "auth_key")
  secure_auth_key = persistent_token("wordpress", new_resource.site, "secure_auth_key")
  logged_in_key = persistent_token("wordpress", new_resource.site, "logged_in_key")
  nonce_key = persistent_token("wordpress", new_resource.site, "nonce_key")
  auth_salt = persistent_token("wordpress", new_resource.site, "auth_salt")
  secure_auth_salt = persistent_token("wordpress", new_resource.site, "secure_auth_salt")
  logged_in_salt = persistent_token("wordpress", new_resource.site, "logged_in_salt")
  nonce_salt = persistent_token("wordpress", new_resource.site, "nonce_salt")

  mysql_user "#{new_resource.database_user}@localhost" do
    password new_resource.database_password
  end

  mysql_database new_resource.database_name do
    permissions "#{new_resource.database_user}@localhost" => :all
  end

  declare_resource :directory, site_directory do
    owner node[:wordpress][:user]
    group node[:wordpress][:group]
    mode "755"
  end

  subversion site_directory do
    action :sync
    repository "https://core.svn.wordpress.org/tags/#{version}"
    user node[:wordpress][:user]
    group node[:wordpress][:group]
    ignore_failure true
  end

  wp_config = edit_file "#{site_directory}/wp-config-sample.php" do |line|
    line.gsub!(/database_name_here/, new_resource.database_name)
    line.gsub!(/username_here/, new_resource.database_user)
    line.gsub!(/password_here/, new_resource.database_password)
    line.gsub!(/wp_/, new_resource.database_prefix)

    line.gsub!(/('AUTH_KEY', *)'put your unique phrase here'/, "\\1'#{auth_key}'")
    line.gsub!(/('SECURE_AUTH_KEY', *)'put your unique phrase here'/, "\\1'#{secure_auth_key}'")
    line.gsub!(/('LOGGED_IN_KEY', *)'put your unique phrase here'/, "\\1'#{logged_in_key}'")
    line.gsub!(/('NONCE_KEY', *)'put your unique phrase here'/, "\\1'#{nonce_key}'")
    line.gsub!(/('AUTH_SALT', *)'put your unique phrase here'/, "\\1'#{auth_salt}'")
    line.gsub!(/('SECURE_AUTH_SALT', *)'put your unique phrase here'/, "\\1'#{secure_auth_salt}'")
    line.gsub!(/('LOGGED_IN_SALT', *)'put your unique phrase here'/, "\\1'#{logged_in_salt}'")
    line.gsub!(/('NONCE_SALT', *)'put your unique phrase here'/, "\\1'#{nonce_salt}'")

    if line =~ /define\('WP_DEBUG'/
      line += "\n"
      line += "/**\n"
      line += " * Don't allow file editing.\n"
      line += " */\n"
      line += "define('DISALLOW_FILE_EDIT', true);\n"
      line += "define('FORCE_SSL_LOGIN', true);\n"
      line += "define('FORCE_SSL_ADMIN', true);\n"
    end

    line
  end

  file "#{site_directory}/wp-config.php" do
    owner node[:wordpress][:user]
    group node[:wordpress][:group]
    mode "644"
    content wp_config
  end

  declare_resource :directory, "#{site_directory}/wp-content/uploads" do
    owner "www-data"
    group "www-data"
    mode "755"
  end

  file "#{site_directory}/sitemap.xml" do
    action :delete
  end

  file "#{site_directory}/sitemap.xml.gz" do
    action :delete
  end

  cookbook_file "#{site_directory}/googlefac54c35e800caab.html" do
    cookbook "wordpress"
    owner node[:wordpress][:user]
    group node[:wordpress][:group]
    mode "644"
    backup false
  end

  ssl_certificate new_resource.site do
    domains [new_resource.site] + Array(new_resource.aliases)
  end

  php_fpm new_resource.site do
    pm_max_children new_resource.fpm_max_children
    pm_start_servers new_resource.fpm_start_servers
    pm_min_spare_servers new_resource.fpm_min_spare_servers
    pm_max_spare_servers new_resource.fpm_max_spare_servers
    request_terminate_timeout new_resource.fpm_request_terminate_timeout
    php_admin_values "open_basedir" => "#{site_directory}/:/usr/share/php/:/tmp/",
                     "disable_functions" => "exec,shell_exec,system,passthru,popen,proc_open"
    php_values "upload_max_filesize" => "70M",
               "post_max_size" => "100M"
    prometheus_port new_resource.fpm_prometheus_port
  end

  apache_site new_resource.site do
    cookbook "wordpress"
    template "apache.erb"
    directory site_directory
    variables :aliases => Array(new_resource.aliases),
              :urls => new_resource.urls
    reload_apache false
  end

  http_request "https://#{new_resource.site}/wp-admin/upgrade.php" do
    action :nothing
    url "https://#{new_resource.site}/wp-admin/upgrade.php?step=1"
    subscribes :get, "subversion[#{site_directory}]"
  end

  wordpress_plugin "wp-fail2ban" do
    site new_resource.site
    reload_apache false
  end

  script "#{site_directory}/wp-content/plugins/wp-fail2ban" do
    action :nothing
    interpreter "php"
    cwd site_directory
    user "wordpress"
    code <<-WP_FAIL2BAN
    <?php
    @include "wp-config.php";
    @include_once "wp-includes/functions.php";
    @include_once "wp-admin/includes/plugin.php";
    activate_plugin("wp-fail2ban/wp-fail2ban.php", '', false, false);
    ?>
    WP_FAIL2BAN
    subscribes :run, "wordpress_plugin[wp-fail2ban]"
  end
end

action :delete do
  wordpress_plugin "wp-fail2ban" do
    action :delete
    site new_resource.site
    reload_apache false
  end

  apache_site new_resource.site do
    action :delete
    reload_apache false
  end

  declare_resource :directory, site_directory do
    action :delete
    recursive true
  end

  mysql_database new_resource.database_name do
    action :drop
  end

  mysql_user "#{new_resource.database_user}@localhost" do
    action :drop
  end
end

action_class do
  include Chef::Mixin::EditFile
  include Chef::Mixin::PersistentToken

  def site_directory
    new_resource.directory || "/srv/#{new_resource.site}"
  end
end

def after_created
  notifies :reload, "service[apache2]" if reload_apache
end
