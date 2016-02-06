#
# Cookbook Name:: mediawiki
# Recipe:: default
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

include_recipe "memcached"
include_recipe "apache::ssl"
include_recipe "mysql"
include_recipe "git"

# Mediawiki Base Requirements
package "php5"
package "php5-cli"
package "php5-curl"
package "php5-mysql"
package "php5-gd"
package "php-apc"
package "php5-intl"
package "libapache2-mod-php5"

package "php-wikidiff2"

# Mediawiki Image + SVG support
package "imagemagick"
package "librsvg2-bin"

# Mediawiki PDF support via Extension:PdfHandler
package "ghostscript"
package "poppler-utils"

# Mediawiki backup
package "xz-utils"
package "liblz4-tool"

# Mediawiki packages for VisualEditor support
package "curl"
package "parsoid"

template "/etc/mediawiki/parsoid/settings.js" do
  source "parsoid-settings.js.erb"
  owner "root"
  group "root"
  mode 0644
end

service "parsoid" do
  action [:enable]
  supports :status => false, :restart => true, :reload => false
  subscribes :restart, "template[/etc/mediawiki/parsoid/settings.js]"
end

link "/etc/php5/apache2/conf.d/20-wikidiff2.ini" do
  to "../../mods-available/wikidiff2.ini"
end

apache_module "php5"
apache_module "rewrite"
