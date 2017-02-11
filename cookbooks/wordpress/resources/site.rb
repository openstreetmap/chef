#
# Cookbook Name:: wordpress
# Resource:: wordpress_site
#
# Copyright 2015, OpenStreetMap Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

actions :create, :delete
default_action :create

attribute :name, :kind_of => String, :name_attribute => true
attribute :aliases, :kind_of => [String, Array]
attribute :directory, :kind_of => String
attribute :version, :kind_of => String
attribute :database_name, :kind_of => String, :required => true
attribute :database_user, :kind_of => String, :required => true
attribute :database_password, :kind_of => String, :required => true
attribute :database_prefix, :kind_of => String, :default => "wp_"
attribute :ssl_enabled, :kind_of => [TrueClass, FalseClass], :default => false
attribute :urls, :kind_of => Hash, :default => {}
attribute :reload_apache, :kind_of => [TrueClass, FalseClass], :default => true

def after_created
  notifies :reload, "service[apache2]" if reload_apache
end
