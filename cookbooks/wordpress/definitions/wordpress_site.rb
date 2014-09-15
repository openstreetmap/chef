#
# Cookbook Name:: wordpress
# Definition:: wordpress_site
#
# Copyright 2013, OpenStreetMap Foundation
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

define :wordpress_site, :action => [ :create, :enable ] do
  name = params[:name]
  ssl_enabled = params[:ssl_enabled] || false
  aliases = Array(params[:aliases])
  urls = Array(params[:urls])
  directory = params[:directory] || "/srv/#{name}"
  version = params[:version] || Chef::Wordpress.current_version
  database_name = params[:database_name]
  database_user = params[:database_user]
  database_password = params[:database_password]
  database_prefix = params[:database_prefix] || "wp_"

  node.set_unless[:wordpress][:sites][name] = {}

  node.set[:wordpress][:sites][name][:directory] = directory

  node.set_unless[:wordpress][:sites][name][:auth_key] = random_password(64)
  node.set_unless[:wordpress][:sites][name][:secure_auth_key] = random_password(64)
  node.set_unless[:wordpress][:sites][name][:logged_in_key] = random_password(64)
  node.set_unless[:wordpress][:sites][name][:nonce_key] = random_password(64)
  node.set_unless[:wordpress][:sites][name][:auth_salt] = random_password(64)
  node.set_unless[:wordpress][:sites][name][:secure_auth_salt] = random_password(64)
  node.set_unless[:wordpress][:sites][name][:logged_in_salt] = random_password(64)
  node.set_unless[:wordpress][:sites][name][:nonce_salt] = random_password(64)

  mysql_user "#{database_user}@localhost" do
    password database_password
  end

  mysql_database database_name do
    permissions "#{database_user}@localhost" => :all
  end

  directory directory do
    owner node[:wordpress][:user]
    group node[:wordpress][:group]
    mode 0755
  end

  subversion directory do
    action :sync
    repository "http://core.svn.wordpress.org/tags/#{version}"
    user node[:wordpress][:user]
    group node[:wordpress][:group]
    ignore_failure true
    notifies :reload, "service[apache2]"
  end

  wp_config = edit_file "#{directory}/wp-config-sample.php" do |line|
    line.gsub!(/database_name_here/, database_name)
    line.gsub!(/username_here/, database_user)
    line.gsub!(/password_here/, database_password)
    line.gsub!(/wp_/, database_prefix)

    line.gsub!(/('AUTH_KEY', *)'put your unique phrase here'/, "\\1'#{node[:wordpress][:sites][name][:auth_key]}'")
    line.gsub!(/('SECURE_AUTH_KEY', *)'put your unique phrase here'/, "\\1'#{node[:wordpress][:sites][name][:secure_auth_key]}'")
    line.gsub!(/('LOGGED_IN_KEY', *)'put your unique phrase here'/, "\\1'#{node[:wordpress][:sites][name][:logged_in_key]}'")
    line.gsub!(/('NONCE_KEY', *)'put your unique phrase here'/, "\\1'#{node[:wordpress][:sites][name][:nonce_key]}'")
    line.gsub!(/('AUTH_SALT', *)'put your unique phrase here'/, "\\1'#{node[:wordpress][:sites][name][:auth_salt]}'")
    line.gsub!(/('SECURE_AUTH_SALT', *)'put your unique phrase here'/, "\\1'#{node[:wordpress][:sites][name][:secure_auth_salt]}'")
    line.gsub!(/('LOGGED_IN_SALT', *)'put your unique phrase here'/, "\\1'#{node[:wordpress][:sites][name][:logged_in_salt]}'")
    line.gsub!(/('NONCE_SALT', *)'put your unique phrase here'/, "\\1'#{node[:wordpress][:sites][name][:nonce_salt]}'")

    if line =~ /define\('WP_DEBUG'/
      line += "\n"
      line += "/**\n"
      line += " * Don't allow file editing.\n"
      line += " */\n"
      line += "define('DISALLOW_FILE_EDIT', true);\n"
      if ssl_enabled
        line += "define('FORCE_SSL_LOGIN', true);\n"
        line += "define('FORCE_SSL_ADMIN', true);\n"
      end
    end

    line
  end

  file "#{directory}/wp-config.php" do
    owner node[:wordpress][:user]
    group node[:wordpress][:group]
    mode 0644
    content wp_config
    notifies :reload, "service[apache2]"
  end

  directory "#{directory}/wp-content/uploads" do
    owner "www-data"
    group "www-data"
    mode 0755
  end

  file "#{directory}/sitemap.xml" do
    action :delete
  end

  file "#{directory}/sitemap.xml.gz" do
    action :delete
  end

  cookbook_file "#{directory}/googlefac54c35e800caab.html" do
    cookbook "wordpress"
    owner node[:wordpress][:user]
    group node[:wordpress][:group]
    mode 0644
    backup false
  end

  apache_site name do
    cookbook "wordpress"
    template "apache.erb"
    directory directory
    variables :aliases => aliases, :urls => urls, :ssl_enabled => ssl_enabled
    notifies :reload, "service[apache2]"
  end

  http_request "http://#{name}/wp-admin/upgrade.php" do
    action :nothing
    url "http://#{name}/wp-admin/upgrade.php?step=1"
    subscribes :get, "subversion[#{directory}]"
  end

  wordpress_plugin "wp-fail2ban" do
    site name
  end

  script "#{directory}/wp-content/plugins/wp-fail2ban" do
    action :nothing
    interpreter "php"
    cwd directory
    user "wordpress"
    code <<-EOS
    <?php
    @include "wp-config.php";
    @include_once "wp-includes/functions.php";
    @include_once "wp-admin/includes/plugin.php";
    activate_plugin("wp-fail2ban/wp-fail2ban.php", '', false, false);
    ?>
    EOS
    subscribes :run, "subversion[#{directory}/wp-content/plugins/wp-fail2ban]"
  end
end
