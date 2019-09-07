#
# Cookbook:: mysql
# Resource:: mysql_database
#
# Copyright:: 2013, OpenStreetMap Foundation
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

property :database, :kind_of => String, :name_property => true
property :permissions, :kind_of => Hash, :default => {}

action :create do
  unless mysql_databases.include?(new_resource.database)
    converge_by("create #{new_resource}") do
      Chef::Log.info("Creating #{new_resource}")
      mysql_execute(:command => "CREATE DATABASE `#{new_resource.database}`")
    end
  end

  current_permissions = mysql_databases[new_resource.database]&.dig(:permissions) || {}

  new_permissions = Hash[new_resource.permissions.collect do |user, privileges|
    [mysql_canonicalise_user(user), privileges]
  end]

  current_permissions.each_key do |user|
    next if new_permissions[user]

    converge_by("revoke all for #{user} on #{new_resource}") do
      Chef::Log.info("Revoking all for #{user} on #{new_resource}")
      mysql_execute(:command => "REVOKE ALL ON `#{new_resource.database}`.* FROM #{user}")
    end
  end

  new_permissions.each do |user, new_privileges|
    current_privileges = current_permissions[user] || {}
    new_privileges = Array(new_privileges)

    if new_privileges.include?(:all)
      new_privileges |= (OpenStreetMap::MySQL::DATABASE_PRIVILEGES - [:grant])
    end

    OpenStreetMap::MySQL::DATABASE_PRIVILEGES.each do |privilege|
      if new_privileges.include?(privilege)
        unless current_privileges.include?(privilege)
          converge_by("grant #{privilege} for #{user} on mysql database #{new_resource}") do
            Chef::Log.info("Granting #{privilege} for #{user} on mysql database #{new_resource}")
            mysql_execute(:command => "GRANT #{mysql_privilege_name(privilege)} ON `#{new_resource.database}`.* TO #{user}")
          end
        end
      elsif current_privileges.include?(privilege)
        converge_by("revoke #{privilege} for #{user} on #{new_resource}") do
          Chef::Log.info("Revoking #{privilege} for #{user} on #{new_resource}")
          mysql_execute(:command => "REVOKE #{mysql_privilege_name(privilege)} ON `#{new_resource.database}`.* FROM #{user}")
        end
      end
    end
  end
end

action :drop do
  if mysql_databases.include?(new_resource.database)
    converge_by("drop #{new_resource}") do
      Chef::Log.info("Dropping #{new_resource}")
      mysql_execute(:command => "DROP DATABASE `#{new_resource.database}`")
    end
  end
end

action_class do
  include OpenStreetMap::MySQL
end
