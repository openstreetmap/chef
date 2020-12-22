#
# Cookbook:: mediawiki
# Recipe:: default
#
# Copyright:: 2013, OpenStreetMap Foundation
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

include_recipe "accounts"
include_recipe "apache"
include_recipe "apt"
include_recipe "git"
include_recipe "memcached"
include_recipe "mysql"
include_recipe "php::fpm"

# Mediawiki Base Requirements
package %w[
  php-cli
  php-curl
  php-gd
  php-intl
  php-mbstring
  php-mysql
  php-xml
  php-zip
  composer
  unzip
]

# Mediawiki enhanced difference engine
package "php-wikidiff2"

# Mediawiki Image + SVG support
package %w[
  imagemagick
  librsvg2-bin
]

# Mediawiki PDF support via Extension:PdfHandler
package %w[
  ghostscript
  poppler-utils
]

# Mediawiki backup
package %w[
  xz-utils
  liblz4-tool
]

# Mediawiki packages for VisualEditor support
package %w[
  curl
  parsoid
]

# Mediawiki packages for SyntaxHighight support
package "python3-pygments"

file "/etc/mediawiki/parsoid/settings.js" do
  action :delete
end

template "/etc/mediawiki/parsoid/config.yaml" do
  action :nothing
  source "parsoid-config.yaml.erb"
  owner "root"
  group "root"
  mode "644"
end

notify_group "parsoid-config" do
  action :run
  notifies :create, "template[/etc/mediawiki/parsoid/config.yaml]"
end

service "parsoid" do
  action [:enable]
  supports :status => false, :restart => true, :reload => false
  subscribes :restart, "file[/etc/mediawiki/parsoid/settings.js]"
  subscribes :restart, "template[/etc/mediawiki/parsoid/config.yaml]"
end

link "/etc/php/#{node[:php][:version]}/fpm/conf.d/20-wikidiff2.ini" do
  to "../../mods-available/wikidiff2.ini"
end

apache_module "proxy"
apache_module "proxy_fcgi"
apache_module "rewrite"
