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

package %w[
  php
  php-cli
  php-apcu
]

# Required for osmosis
package "default-jre-headless"

# Required for building gosmore
package %w[
  build-essential
  libxml2-dev
  libgtk2.0-dev
  subversion
  libcurl4-gnutls-dev
  libgps-dev libcurl3
  buffer
  git
  cmake
  libqt4-dev
  qt4-dev-tools
  qt4-linguist-tools
  libicu-dev
]

apache_module "php7.0"
