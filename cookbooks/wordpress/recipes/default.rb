#
# Cookbook Name:: wordpress
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

include_recipe "apache::ssl"
include_recipe "mysql"

package "subversion"

package "php5"
package "php5-mysql"

package "php-apc"

apache_module "php5"
apache_module "rewrite"

fail2ban_filter "wordpress" do
  source "https://plugins.svn.wordpress.org/wp-fail2ban/trunk/filters.d/wordpress-hard.conf"
end

fail2ban_jail "wordpress" do
  filter "wordpress"
  logpath "/var/log/auth.log"
  ports [80, 443]
  maxretry 6
end
