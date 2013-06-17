#
# Cookbook Name:: drupal
# Definition:: drupal_site
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

define :drupal_site, :action => [ :create ], :variables => {} do
  site_name = params[:name]
  site_action = params[:action]
  site_title = params[:title] || site_name
  short_name = site_name.sub(/\..*$/, "")
  db_name = params[:database_name] || short_name
  db_username = params[:database_username] || short_name
  db_password = params[:database_password]
  db_url = "mysql://#{db_username}:#{db_password}@localhost/#{db_name}"
  admin_username = params[:admin_username] || "admin"
  admin_password = params[:admin_password]
  admin_email = params[:admin_email] || "webmaster@openstreetmap.org"
  ssl = params[:ssl] || false

  if site_action.include?(:create)
    directory "/data/#{site_name}" do
      owner "www-data"
      group "www-data"
      mode "0775"
      recursive true
    end

    directory "/data/#{site_name}/files" do
      owner "www-data"
      group "www-data"
      mode "0775"
    end

    directory "/data/#{site_name}/private" do
      owner "www-data"
      group "www-data"
      mode "0775"
    end

    directory "/etc/drupal/7/sites/#{site_name}" do
      owner "root"
      group "root"
      mode "0555"
    end

    link "/etc/drupal/7/sites/#{site_name}/files" do
      to "/data/#{site_name}/files"
    end

    link "/etc/drupal/7/sites/#{site_name}/private" do
      to "/data/#{site_name}/private"
    end

    execute "drupal-site-install-#{short_name}" do
      command "drush site-install --account-name=#{admin_username} --account-pass=#{admin_password} --account-mail=#{admin_email} --db-url=#{db_url} --site-name=#{site_title} --site-mail=webmaster@openstreetmap.org --sites-subdir=#{site_name} --yes"
      cwd "/usr/share/drupal7"
      user "root"
      group "root"
      creates "/etc/drupal/7/sites/#{site_name}/settings.php"
    end

    apache_site site_name do
      cookbook "drupal"
      template ssl ? "apache-ssl.erb" : "apache.erb"
    end
  elsif site_action.include?(:delete)
  end
end
