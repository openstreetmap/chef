#
# Cookbook Name:: yournavigation
# Recipe:: default
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

include_recipe "apache"

package "php5"
package "php5-cli"

package "php-apc"

# Required for osmosis
package "default-jre-headless"

# Required for building gosmore
package "build-essential"
package "libxml2-dev"
package "libgtk2.0-dev"
package "subversion"
package "libcurl4-gnutls-dev"
package "libgps-dev"
package "libcurl3"
package "buffer"
package "git"
package "cmake"
package "libqt4-core"
package "libqt4-dev"
package "qt4-dev-tools"
package "qt4-linguist-tools"
package "libicu52"

apache_module "php5"
