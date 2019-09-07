#
# Cookbook:: mysql
# Resource:: mysql_user
#
# Copyright:: 2012, OpenStreetMap Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default_action :create

property :user, :kind_of => String, :name_property => true
property :password, :kind_of => String

OpenStreetMap::MySQL::USER_PRIVILEGES.each do |privilege|
  property privilege, :default => false
end

action :create do
  user = mysql_canonicalise_user(new_resource.user)
  password = new_resource.password ? "IDENTIFIED BY '#{new_resource.password}'" : ""

  unless mysql_users.include?(user)
    converge_by("create #{new_resource}") do
      Chef::Log.info("Creating #{new_resource}")
      mysql_execute(:command => "CREATE USER #{user} #{password}")
    end
  end

  current_privileges = mysql_users.fetch(new_resource.user, {})

  new_privileges = Hash[OpenStreetMap::MySQL::USER_PRIVILEGES.collect do |privilege|
    [privilege, new_resource.send(privilege)]
  end]

  new_privileges.each do |privilege, new_enabled|
    old_enabled = current_privileges.fetch(privilege, false)

    if new_enabled && !old_enabled
      converge_by("grant #{privilege} for #{new_resource}") do
        Chef::Log.info("Granting #{privilege} for #{new_resource}")
        mysql_execute(:command => "GRANT #{mysql_privilege_name(privilege)} ON *.* TO #{user}")
      end
    elsif old_enabled && !new_enabled
      converge_by("revoke #{privilege} for #{new_resource}") do
        Chef::Log.info("Revoking #{privilege} for #{new_resource}")
        mysql_execute(:command => "REVOKE #{mysql_privilege_name(privilege)} ON *.* FROM #{user}")
      end
    end
  end
end

action :drop do
  user = mysql_canonicalise_user(new_resource.user)

  if mysql_users.include?(user)
    converge_by("drop #{new_resource}") do
      Chef::Log.info("Dropping #{new_resource}")
      mysql_execute(:command => "DROP USER #{user}")
    end
  end
end

action_class do
  include OpenStreetMap::MySQL
end
