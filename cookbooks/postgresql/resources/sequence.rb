#
# Cookbook:: postgresql
# Resource:: postgresql_sequence
#
# Copyright:: 2023, OpenStreetMap Foundation
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

property :sequence, :kind_of => String, :name_property => true
property :cluster, :kind_of => String, :required => true
property :database, :kind_of => String, :required => true
property :schema, :kind_of => String, :default => "public"
property :owner, :kind_of => String, :required => [:create]
property :permissions, :kind_of => Hash, :default => {}

action :create do
  if sequences.include?(qualified_name)
    if new_resource.owner != sequences[qualified_name][:owner]
      converge_by("set owner for #{new_resource} to #{new_resource.owner}") do
        Chef::Log.info("Setting owner for #{new_resource} to #{new_resource.owner}")
        cluster.execute(:command => "ALTER SEQUENCE #{qualified_name} OWNER TO \"#{new_resource.owner}\"", :database => new_resource.database)
      end
    end

    sequences[qualified_name][:permissions].each_key do |user|
      next if new_resource.permissions[user]

      converge_by("revoke all for #{user} on #{new_resource}") do
        Chef::Log.info("Revoking all for #{user} on #{new_resource}")
        cluster.execute(:command => "REVOKE ALL ON TABLE #{qualified_name} FROM \"#{user}\"", :database => new_resource.database)
      end
    end

    new_resource.permissions.each do |user, new_privileges|
      current_privileges = sequences[qualified_name][:permissions][user] || {}
      new_privileges = Array(new_privileges)

      if new_privileges.include?(:all)
        new_privileges |= OpenStreetMap::PostgreSQL::SEQUENCE_PRIVILEGES
      end

      OpenStreetMap::PostgreSQL::SEQUENCE_PRIVILEGES.each do |privilege|
        if new_privileges.include?(privilege)
          unless current_privileges.include?(privilege)
            converge_by("grant #{privilege} for #{user} on #{new_resource}") do
              Chef::Log.info("Granting #{privilege} for #{user} on #{new_resource}")
              cluster.execute(:command => "GRANT #{privilege.to_s.upcase} ON SEQUENCE #{qualified_name} TO \"#{user}\"", :database => new_resource.database)
            end
          end
        elsif current_privileges.include?(privilege)
          converge_by("revoke #{privilege} for #{user} on #{new_resource}") do
            Chef::Log.info("Revoking #{privilege} for #{user} on #{new_resource}")
            cluster.execute(:command => "REVOKE #{privilege.to_s.upcase} ON SEQUENCE #{qualified_name} FROM \"#{user}\"", :database => new_resource.database)
          end
        end
      end
    end
  end
end

action :drop do
  if sequences.include?(qualified_name)
    converge_by("drop #{new_resource}") do
      Chef::Log.info("Dropping #{new_resource}")
      cluster.execute(:command => "DROP SEQUENCE #{qualified_name}", :database => new_resource.database)
    end
  end
end

action_class do
  def cluster
    @cluster ||= OpenStreetMap::PostgreSQL.new(new_resource.cluster)
  end

  def sequences
    @sequences ||= cluster.sequences(new_resource.database)
  end

  def qualified_name
    "#{new_resource.schema}.#{new_resource.name}"
  end
end
