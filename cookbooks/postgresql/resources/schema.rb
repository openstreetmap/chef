#
# Cookbook:: postgresql
# Resource:: postgresql_schema
#
# Copyright:: 2024, OpenStreetMap Foundation
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

unified_mode true

default_action :create

property :schema, :kind_of => String, :name_property => true
property :cluster, :kind_of => String, :required => true
property :database, :kind_of => String, :required => true
property :owner, :kind_of => String, :required => [:create]
property :permissions, :kind_of => Hash, :default => {}

action :create do
  if schemas.include?(qualified_name)
    # Handle the case of an existing schema
    if new_resource.owner != schemas[qualified_name][:owner]
      converge_by("set owner for #{new_resource} to #{new_resource.owner}") do
        Chef::Log.info("Setting owner for #{new_resource} to #{new_resource.owner}")
        cluster.execute(:command => "ALTER SCHEMA #{qualified_name} OWNER TO \"#{new_resource.owner}\"", :database => new_resource.database)
      end
    end

    schemas[qualified_name][:permissions].each_key do |user|
      next if new_resource.permissions[user]
      # Remove permissions from users who no longer have them
      converge_by("revoke all for #{user} on #{new_resource}") do
        Chef::Log.info("Revoking all for #{user} on #{new_resource}")
        cluster.execute(:command => "REVOKE ALL ON SCHEMA #{qualified_name} FROM \"#{user}\"", :database => new_resource.database)
      end
    end
    new_resource.permissions.each do |user, new_privileges|
      current_privileges = schemas[qualified_name][:permissions][user] || {}
      new_privileges = Array(new_privileges)

      if new_privileges.include?(:all)
        new_privileges |= OpenStreetMap::PostgreSQL::SCHEMA_PRIVILEGES
      end

      OpenStreetMap::PostgreSQL::SCHEMA_PRIVILEGES.each do |privilege|
        if new_privileges.include?(privilege)
          unless current_privileges.include?(privilege)
            converge_by("grant #{privilege} for #{user} on #{new_resource}") do
              Chef::Log.info("Granting #{privilege} for #{user} on #{new_resource}")
              cluster.execute(:command => "GRANT #{privilege.to_s.upcase} ON SCHEMA #{qualified_name} TO \"#{user}\"", :database => new_resource.database)
            end
          end
        elsif current_privileges.include?(privilege)
          converge_by("revoke #{privilege} for #{user} on #{new_resource}") do
            Chef::Log.info("Revoking #{privilege} for #{user} on #{new_resource}")
            cluster.execute(:command => "REVOKE #{privilege.to_s.upcase} ON SCHEMA #{qualified_name} FROM \"#{user}\"", :database => new_resource.database)
          end
        end
      end
    end
  else
    converge_by "create schema #{new_resource.schema}" do
      cluster.execute(:command => "CREATE SCHEMA #{new_resource.schema} AUTHORIZATION #{new_resource.owner}", :database => new_resource.database)
      # Because the schema is new, we don't have to worry about revoking or checking current permissions
      new_resource.permissions.each do |user, new_privileges|
        new_privileges = Array(new_privileges)
        if new_privileges.include?(:all)
          new_privileges |= OpenStreetMap::PostgreSQL::SCHEMA_PRIVILEGES
        end
        OpenStreetMap::PostgreSQL::SCHEMA_PRIVILEGES.each do |privilege|
          next unless new_privileges.include?(privilege)
          converge_by("grant #{privilege} for #{user} on #{new_resource}") do
            Chef::Log.info("Granting #{privilege} for #{user} on #{new_resource}")
            cluster.execute(:command => "GRANT #{privilege.to_s.upcase} ON SCHEMA #{qualified_name} TO \"#{user}\"", :database => new_resource.database)
          end
        end
      end
    end
  end
end

action :drop do
  if schemas.include?(qualified_name)
    converge_by("drop #{new_resource}") do
      Chef::Log.info("Dropping #{new_resource}")
      cluster.execute(:command => "DROP SCHEMA #{qualified_name}", :database => new_resource.database)
    end
  end
end

action_class do
  def cluster
    @cluster ||= OpenStreetMap::PostgreSQL.new(new_resource.cluster)
  end

  def schemas
    @schemas ||= cluster.schemas(new_resource.database)
  end

  def qualified_name
    "#{new_resource.name}"
  end
end
