#
# Cookbook Name:: wordpress
# Provider:: wordpress_site
#
# Copyright 2015, OpenStreetMap Foundation
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

require "securerandom"

include Chef::Mixin::EditFile

def whyrun_supported?
  true
end

use_inline_resources

action :create do
  version = new_resource.version || Chef::Wordpress.current_version

  node.normal_unless[:wordpress][:sites][new_resource.name] = {}

  node.normal[:wordpress][:sites][new_resource.name][:directory] = site_directory

  node.normal_unless[:wordpress][:sites][new_resource.name][:auth_key] = SecureRandom.base64(48)
  node.normal_unless[:wordpress][:sites][new_resource.name][:secure_auth_key] = SecureRandom.base64(48)
  node.normal_unless[:wordpress][:sites][new_resource.name][:logged_in_key] = SecureRandom.base64(48)
  node.normal_unless[:wordpress][:sites][new_resource.name][:nonce_key] = SecureRandom.base64(48)
  node.normal_unless[:wordpress][:sites][new_resource.name][:auth_salt] = SecureRandom.base64(48)
  node.normal_unless[:wordpress][:sites][new_resource.name][:secure_auth_salt] = SecureRandom.base64(48)
  node.normal_unless[:wordpress][:sites][new_resource.name][:logged_in_salt] = SecureRandom.base64(48)
  node.normal_unless[:wordpress][:sites][new_resource.name][:nonce_salt] = SecureRandom.base64(48)

  mysql_user "#{new_resource.database_user}@localhost" do
    password new_resource.database_password
  end

  mysql_database new_resource.database_name do
    permissions "#{new_resource.database_user}@localhost" => :all
  end

  directory site_directory do
    owner node[:wordpress][:user]
    group node[:wordpress][:group]
    mode 0o755
  end

  subversion site_directory do
    action :sync
    repository "http://core.svn.wordpress.org/tags/#{version}"
    user node[:wordpress][:user]
    group node[:wordpress][:group]
    ignore_failure true
  end

  wp_config = edit_file "#{site_directory}/wp-config-sample.php" do |line|
    line.gsub!(/database_name_here/, new_resource.database_name)
    line.gsub!(/username_here/, new_resource.database_user)
    line.gsub!(/password_here/, new_resource.database_password)
    line.gsub!(/wp_/, new_resource.database_prefix)

    line.gsub!(/('AUTH_KEY', *)'put your unique phrase here'/, "\\1'#{node[:wordpress][:sites][new_resource.name][:auth_key]}'")
    line.gsub!(/('SECURE_AUTH_KEY', *)'put your unique phrase here'/, "\\1'#{node[:wordpress][:sites][new_resource.name][:secure_auth_key]}'")
    line.gsub!(/('LOGGED_IN_KEY', *)'put your unique phrase here'/, "\\1'#{node[:wordpress][:sites][new_resource.name][:logged_in_key]}'")
    line.gsub!(/('NONCE_KEY', *)'put your unique phrase here'/, "\\1'#{node[:wordpress][:sites][new_resource.name][:nonce_key]}'")
    line.gsub!(/('AUTH_SALT', *)'put your unique phrase here'/, "\\1'#{node[:wordpress][:sites][new_resource.name][:auth_salt]}'")
    line.gsub!(/('SECURE_AUTH_SALT', *)'put your unique phrase here'/, "\\1'#{node[:wordpress][:sites][new_resource.name][:secure_auth_salt]}'")
    line.gsub!(/('LOGGED_IN_SALT', *)'put your unique phrase here'/, "\\1'#{node[:wordpress][:sites][new_resource.name][:logged_in_salt]}'")
    line.gsub!(/('NONCE_SALT', *)'put your unique phrase here'/, "\\1'#{node[:wordpress][:sites][new_resource.name][:nonce_salt]}'")

    if line =~ /define\('WP_DEBUG'/
      line += "\n"
      line += "/**\n"
      line += " * Don't allow file editing.\n"
      line += " */\n"
      line += "define('DISALLOW_FILE_EDIT', true);\n"
      if new_resource.ssl_enabled
        line += "define('FORCE_SSL_LOGIN', true);\n"
        line += "define('FORCE_SSL_ADMIN', true);\n"
      end
    end

    line
  end

  file "#{site_directory}/wp-config.php" do
    owner node[:wordpress][:user]
    group node[:wordpress][:group]
    mode 0o644
    content wp_config
  end

  directory "#{site_directory}/wp-content/uploads" do
    owner "www-data"
    group "www-data"
    mode 0o755
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
    mode 0o644
    backup false
  end

  ssl_certificate new_resource.name do
    domains [new_resource.name] + Array(new_resource.aliases)
    only_if { new_resource.ssl_enabled }
  end

  apache_site new_resource.name do
    cookbook "wordpress"
    template "apache.erb"
    directory site_directory
    variables :aliases => Array(new_resource.aliases),
              :urls => new_resource.urls,
              :ssl_enabled => new_resource.ssl_enabled
    reload_apache false
  end

  http_request "http://#{new_resource.name}/wp-admin/upgrade.php" do
    action :nothing
    url "http://#{new_resource.name}/wp-admin/upgrade.php?step=1"
    subscribes :get, "subversion[#{site_directory}]"
  end

  wordpress_plugin "wp-fail2ban" do
    site new_resource.name
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
    site new_resource.name
    reload_apache false
  end

  apache_site new_resource.name do
    action :delete
    reload_apache false
  end

  directory site_directory do
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

def site_directory
  new_resource.directory || "/srv/#{new_resource.name}"
end
