#
# Cookbook:: dmca
# Recipe:: default
#
# Copyright:: 2018, OpenStreetMap Foundation
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

include_recipe "apache"
include_recipe "php::fpm"

apache_module "proxy"
apache_module "proxy_fcgi"

package "composer"

git "/srv/dmca.openstreetmap.org" do
  action :sync
  repository "https://github.com/openstreetmap/dmca-website.git"
  revision "main"
  depth 1
  notifies :run, "execute[/srv/dmca.openstreetmap.org/composer.json]", :immediately
end

execute "/srv/dmca.openstreetmap.org/composer.json" do
  action :nothing
  command "composer install --no-dev"
  cwd "/srv/dmca.openstreetmap.org/"
  environment "COMPOSER_HOME" => "/srv/dmca.openstreetmap.org/"
end

ssl_certificate "dmca.openstreetmap.org" do
  domains ["dmca.openstreetmap.org", "dmca.osm.org"]
  notifies :reload, "service[apache2]"
end

php_fpm "dmca.openstreetmap.org" do
  php_admin_values "open_basedir" => "/srv/dmca.openstreetmap.org/:/usr/share/php/:/tmp/",
                   "disable_functions" => "exec,shell_exec,system,passthru,popen,proc_open"
  prometheus_port 11201
end

apache_site "dmca.openstreetmap.org" do
  template "apache.erb"
  directory "/srv/dmca.openstreetmap.org"
  variables :aliases => ["dmca.osm.org"]
end
