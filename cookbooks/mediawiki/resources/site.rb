#
# Cookbook Name:: mediawiki
# Resource:: mediawiki_site
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

actions :create, :update, :delete
default_action :create

attribute :name, :kind_of => String, :name_attribute => true
attribute :aliases, :kind_of => [String, Array]
attribute :directory, :kind_of => String
attribute :version, :kind_of => String, :default => "1.26"
attribute :database_name, :kind_of => String, :required => true
attribute :database_user, :kind_of => String, :required => true
attribute :database_password, :kind_of => String, :required => true
attribute :sitename, :kind_of => String, :default => "OpenStreetMap Wiki"
attribute :metanamespace, :kind_of => String, :default => "OpenStreetMap"
attribute :logo, :kind_of => String, :default => "$wgStylePath/common/images/wiki.png"
attribute :email_contact, :kind_of => String, :default => ""
attribute :email_sender, :kind_of => String, :default => ""
attribute :email_sender_name, :kind_of => String, :default => "MediaWiki Mail"
attribute :commons, :kind_of => [TrueClass, FalseClass], :default => true
attribute :skin, :kind_of => String, :default => "vector"
attribute :site_notice, :kind_of => String, :default => ""
attribute :site_readonly, :kind_of => [TrueClass, FalseClass], :default => false
attribute :admin_user, :kind_of => String, :default => "Admin"
attribute :admin_password, :kind_of => String, :required => true
attribute :ssl_enabled, :kind_of => [TrueClass, FalseClass], :default => false
attribute :ssl_certificate, :kind_of => String
attribute :ssl_certificate_chain, :kind_of => String
attribute :private_accounts, :kind_of => [TrueClass, FalseClass], :default => false
attribute :private, :kind_of => [TrueClass, FalseClass], :default => false
attribute :recaptcha_public_key, :kind_of => String
attribute :recaptcha_private_key, :kind_of => String
attribute :extra_file_extensions, :kind_of => [String, Array], :default => []
attribute :reload_apache, :kind_of => [TrueClass, FalseClass], :default => true

def after_created
  notifies :reload, "service[apache2]" if reload_apache
end

def database_params
  {
    :host => "localhost",
    :name => database_name,
    :username => database_user,
    :password => database_password
  }
end

def mediawiki_params
  {
    :sitename => sitename,
    :metanamespace => metanamespace,
    :logo => logo,
    :email_contact => email_contact,
    :email_sender => email_sender,
    :email_sender_name => email_sender_name,
    :commons => commons,
    :skin => skin,
    :site_notice => site_notice,
    :site_readonly => site_readonly,
    :ssl_enabled => ssl_enabled,
    :extra_file_extensions => extra_file_extensions,
    :private_accounts => private_accounts,
    :private => private
  }
end
