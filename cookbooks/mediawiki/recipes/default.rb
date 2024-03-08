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
  php-apcu
  php-cli
  php-curl
  php-gd
  php-igbinary
  php-intl
  php-memcache
  php-mbstring
  php-mysql
  php-xml
  php-zip
  composer
  unzip
  ffmpeg
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
]

# Mediawiki packages for SyntaxHighight support
package "python3-pygments"

link "/etc/php/#{node[:php][:version]}/fpm/conf.d/20-wikidiff2.ini" do
  to "../../mods-available/wikidiff2.ini"
end

apache_module "proxy"
apache_module "proxy_fcgi"
apache_module "rewrite"

systemd_service "mediawiki-sitemap@" do
  description "Generate sitemap.xml for %i"
  exec_start "/usr/bin/php -d memory_limit=2048M -d error_reporting=22517 /srv/%i/w/maintenance/generateSitemap.php --server=https://%i --urlpath=https://%i/ --fspath=/srv/%i --quiet --skip-redirects"
  user node[:mediawiki][:user]
  nice 10
  sandbox :enable_network => true
  memory_deny_write_execute false
  restrict_address_families "AF_UNIX"
  read_write_paths "/srv/%i"
end

systemd_timer "mediawiki-sitemap@" do
  description "Generate sitemap.xml for %i"
  on_calendar "00:30"
end

systemd_service "mediawiki-jobs@" do
  description "Run mediawiki jobs for %i"
  exec_start "/usr/bin/php -d memory_limit=2048M -d error_reporting=22517 /srv/%i/w/maintenance/runJobs.php --server=https://%i --maxtime=175 --memory-limit=2048M --procs=8"
  user node[:mediawiki][:user]
  nice 10
  runtime_max_sec 3600
  sandbox :enable_network => true
  memory_deny_write_execute false
  restrict_address_families "AF_UNIX"
  read_write_paths "/srv/%i"
end

systemd_timer "mediawiki-jobs@" do
  description "Run mediawiki jobs for %i"
  on_boot_sec "3m"
  on_unit_inactive_sec "3m"
end

systemd_service "mediawiki-email-jobs@" do
  description "Run mediawiki email jobs for %i"
  exec_start "/usr/bin/php -d memory_limit=2048M -d error_reporting=22517 /srv/%i/w/maintenance/runJobs.php --server=https://%i --maxtime=55 --type=enotifNotify --memory-limit=2048M --procs=4"
  user node[:mediawiki][:user]
  nice 10
  runtime_max_sec 3600
  sandbox :enable_network => true
  memory_deny_write_execute false
  restrict_address_families "AF_UNIX"
  read_write_paths "/srv/%i"
end

systemd_timer "mediawiki-email-jobs@" do
  description "Run mediawiki email jobs for %i"
  on_boot_sec "1m"
  on_unit_inactive_sec "1m"
end

systemd_service "mediawiki-cleanup-gs" do
  description "Clean up imagemagick gs_* files"
  exec_start "/usr/bin/find /tmp -maxdepth 1 -type f -user www-data -mmin +90 -name 'gs_*' -delete"
  user node[:mediawiki][:user]
  sandbox true
end

systemd_timer "mediawiki-cleanup-gs" do
  description "Clean up imagemagick gs_* files"
  on_calendar "02:10"
end

service "mediawiki-cleanup-gs.timer" do
  action [:enable, :start]
end

systemd_service "mediawiki-cleanup-magick" do
  description "Clean up imagemagick magick-* files"
  exec_start "/usr/bin/find /tmp -maxdepth 1 -type f -user www-data -mmin +90 -name 'magick-*' -delete"
  user node[:mediawiki][:user]
  sandbox true
end

systemd_timer "mediawiki-cleanup-magick" do
  description "Clean up imagemagick magick-* files"
  on_calendar "02:20"
end

service "mediawiki-cleanup-magick.timer" do
  action [:enable, :start]
end
