#
# Cookbook Name:: postgresql
# Provider:: postgresql_table
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
  @pg = Chef::PostgreSQL.new(new_resource.cluster)
  @tables = @pg.tables(new_resource.database)
  @name = "#{new_resource.schema}.#{new_resource.name}"

  @current_resource = Chef::Resource::PostgresqlTable.new(new_resource.name)
  @current_resource.cluster(new_resource.cluster)
  @current_resource.database(new_resource.database)
  @current_resource.schema(new_resource.schema)
  if (pg_table = @tables[@name])
    @current_resource.owner(pg_table[:owner])
    @current_resource.permissions(pg_table[:permissions])
  end
  @current_resource
end

action :create do
  if @tables.include?(@name)
    if new_resource.owner != @current_resource.owner
      converge_by("set owner for #{new_resource} to #{new_resource.owner}") do
        Chef::Log.info("Setting owner for #{new_resource} to #{new_resource.owner}")
        @pg.execute(:command => "ALTER TABLE #{@name} OWNER TO \"#{new_resource.owner}\"", :database => new_resource.database)
      end
    end

    @current_resource.permissions.each_key do |user|
      next if new_resource.permissions[user]

      converge_by("revoke all for #{user} on #{new_resource}") do
        Chef::Log.info("Revoking all for #{user} on #{new_resource}")
        @pg.execute(:command => "REVOKE ALL ON #{@name} FROM \"#{user}\"", :database => new_resource.database)
      end
    end

    new_resource.permissions.each do |user, new_privileges|
      current_privileges = @current_resource.permissions[user] || {}
      new_privileges = Array(new_privileges)

      if new_privileges.include?(:all)
        new_privileges |= Chef::PostgreSQL::TABLE_PRIVILEGES
      end

      Chef::PostgreSQL::TABLE_PRIVILEGES.each do |privilege|
        if new_privileges.include?(privilege)
          unless current_privileges.include?(privilege)
            converge_by("grant #{privilege} for #{user} on #{new_resource}") do
              Chef::Log.info("Granting #{privilege} for #{user} on #{new_resource}")
              @pg.execute(:command => "GRANT #{privilege.to_s.upcase} ON #{@name} TO \"#{user}\"", :database => new_resource.database)
            end
          end
        elsif current_privileges.include?(privilege)
          converge_by("revoke #{privilege} for #{user} on #{new_resource}") do
            Chef::Log.info("Revoking #{privilege} for #{user} on #{new_resource}")
            @pg.execute(:command => "REVOKE #{privilege.to_s.upcase} ON #{@name} FROM \"#{user}\"", :database => new_resource.database)
          end
        end
      end
    end
  end
end

action :drop do
  if @tables.include?(@name)
    converge_by("drop #{new_resource}") do
      Chef::Log.info("Dropping #{new_resource}")
      @pg.execute(:command => "DROP TABLE #{@name}", :database => new_resource.database)
    end
  end
end
