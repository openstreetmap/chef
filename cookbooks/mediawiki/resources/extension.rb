#
# Cookbook Name:: mediawiki
# Resource:: mediawiki_extension
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
attribute :site, :kind_of => String, :required => true
attribute :source, :kind_of => String
attribute :template, :kind_of => String
attribute :variables, :kind_of => Hash, :default => {}
attribute :version, :kind_of => String
attribute :repository, :kind_of => String
attribute :tag, :kind_of => String
attribute :update_site, :kind_of => [TrueClass, FalseClass], :default => true

def after_created
  if update_site
    notifies :update, "mediawik_site[site]"
  else
    site_directory = node[:mediawiki][:sites][site][:directory]

    notifies :create, "template[#{site_directory}/w/LocalSettings.php]"
    notifies :run, "execute[#{site_directory}/w/maintenance/update.php]"
  end
end
