#
# Cookbook Name:: postgresql
# Provider:: postgresql_user
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

use_inline_resources

def load_current_resource
  @pg = Chef::PostgreSQL.new(new_resource.cluster)

  @current_resource = Chef::Resource::PostgresqlUser.new(new_resource.name)
  @current_resource.user(new_resource.user)
  @current_resource.cluster(new_resource.cluster)
  if (pg_user = @pg.users[@current_resource.user])
    @current_resource.superuser(pg_user[:superuser])
    @current_resource.createdb(pg_user[:createdb])
    @current_resource.createrole(pg_user[:createrole])
    @current_resource.replication(pg_user[:replication])
  end
  @current_resource
end

action :create do
  password = new_resource.password ? "ENCRYPTED PASSWORD '#{new_resource.password}'" : ""
  superuser = new_resource.superuser ? "SUPERUSER" : "NOSUPERUSER"
  createdb = new_resource.createdb ? "CREATEDB" : "NOCREATEDB"
  createrole = new_resource.createrole ? "CREATEROLE" : "NOCREATEROLE"
  replication = new_resource.replication ? "REPLICATION" : "NOREPLICATION"

  if !@pg.users.include?(new_resource.user)
    @pg.execute(:command => "CREATE ROLE \"#{new_resource.user}\" LOGIN #{password} #{superuser} #{createdb} #{createrole}")
    new_resource.updated_by_last_action(true)
  else
    if new_resource.superuser != @current_resource.superuser
      @pg.execute(:command => "ALTER ROLE \"#{new_resource.user}\" #{superuser}")
      new_resource.updated_by_last_action(true)
    end

    unless new_resource.superuser
      if new_resource.createdb != @current_resource.createdb
        @pg.execute(:command => "ALTER ROLE \"#{new_resource.user}\" #{createdb}")
        new_resource.updated_by_last_action(true)
      end

      if new_resource.createrole != @current_resource.createrole
        @pg.execute(:command => "ALTER ROLE \"#{new_resource.user}\" #{createrole}")
        new_resource.updated_by_last_action(true)
      end

      if new_resource.replication != @current_resource.replication
        @pg.execute(:command => "ALTER ROLE \"#{new_resource.user}\" #{replication}")
        new_resource.updated_by_last_action(true)
      end
    end
  end
end

action :drop do
  if @pg.users.include?(new_resource.user)
    @pg.execute(:command => "DROP ROLE \"#{new_resource.user}\"")
    new_resource.updated_by_last_action(true)
  end
end
