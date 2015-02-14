#
# Cookbook Name:: mysql
# Provider:: mysql_user
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

def load_current_resource
  @mysql = Chef::MySQL.new

  @current_resource = Chef::Resource::MysqlUser.new(new_resource.name)
  @current_resource.user(new_resource.user)
  if (mysql_user = @mysql.users[@current_resource.user])
    Chef::MySQL::USER_PRIVILEGES.each do |privilege|
      @current_resource.send(privilege, mysql_user[privilege])
    end
  end
  @current_resource
end

action :create do
  user = @mysql.canonicalise_user(new_resource.user)
  password = new_resource.password ? "IDENTIFIED BY '#{new_resource.password}'" : ""

  unless @mysql.users.include?(user)
    converge_by("create #{new_resource}") do
      Chef::Log.info("Creating #{new_resource}")
      @mysql.execute(:command => "CREATE USER #{user} #{password}")
    end
  end

  Chef::MySQL::USER_PRIVILEGES.each do |privilege|
    next if new_resource.send(privilege) == @current_resource.send(privilege)

    if new_resource.send(privilege)
      converge_by("grant #{privilege} for #{new_resource}") do
        Chef::Log.info("Granting #{privilege} for #{new_resource}")
        @mysql.execute(:command => "GRANT #{@mysql.privilege_name(privilege)} ON *.* TO #{user}")
      end
    else
      converge_by("revoke #{privilege} for #{new_resource}") do
        Chef::Log.info("Revoking #{privilege} for #{new_resource}")
        @mysql.execute(:command => "REVOKE #{@mysql.privilege_name(privilege)} ON *.* FROM #{user}")
      end
    end
  end
end

action :drop do
  user = @mysql.canonicalise_user(new_resource.user)

  if @mysql.users.include?(user)
    converge_by("drop #{new_resource}") do
      Chef::Log.info("Dropping #{new_resource}")
      @mysql.execute(:command => "DROP USER #{user}")
    end
  end
end
