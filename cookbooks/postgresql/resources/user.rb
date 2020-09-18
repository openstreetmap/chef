#
# Cookbook:: postgresql
# Resource:: postgresql_user
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

require "shellwords"

default_action :create

property :user, :kind_of => String, :name_property => true
property :cluster, :kind_of => String, :required => true
property :password, :kind_of => String
property :superuser, :kind_of => [TrueClass, FalseClass], :default => false
property :createdb, :kind_of => [TrueClass, FalseClass], :default => false
property :createrole, :kind_of => [TrueClass, FalseClass], :default => false
property :replication, :kind_of => [TrueClass, FalseClass], :default => false

action :create do
  password = new_resource.password ? "ENCRYPTED PASSWORD '#{new_resource.password.shellescape}'" : ""
  superuser = new_resource.superuser ? "SUPERUSER" : "NOSUPERUSER"
  createdb = new_resource.createdb ? "CREATEDB" : "NOCREATEDB"
  createrole = new_resource.createrole ? "CREATEROLE" : "NOCREATEROLE"
  replication = new_resource.replication ? "REPLICATION" : "NOREPLICATION"

  if !cluster.users.include?(new_resource.user)
    converge_by "create role #{new_resource.user}" do
      cluster.execute(:command => "CREATE ROLE \"#{new_resource.user}\" LOGIN #{password} #{superuser} #{createdb} #{createrole}")
    end
  else
    current_user = cluster.users[new_resource.user]

    if new_resource.superuser != current_user[:superuser]
      converge_by "alter role #{new_resource.user}" do
        cluster.execute(:command => "ALTER ROLE \"#{new_resource.user}\" #{superuser}")
      end
    end

    unless new_resource.superuser
      if new_resource.createdb != current_user[:createdb]
        converge_by "alter role #{new_resource.user}" do
          cluster.execute(:command => "ALTER ROLE \"#{new_resource.user}\" #{createdb}")
        end
      end

      if new_resource.createrole != current_user[:createrole]
        converge_by "alter role #{new_resource.user}" do
          cluster.execute(:command => "ALTER ROLE \"#{new_resource.user}\" #{createrole}")
        end
      end

      if new_resource.replication != current_user[:replication]
        converge_by "alter role #{new_resource.user}" do
          cluster.execute(:command => "ALTER ROLE \"#{new_resource.user}\" #{replication}")
        end
      end
    end
  end
end

action :drop do
  if cluster.users.include?(new_resource.user)
    converge_by "drop role #{new_resource.user}" do
      cluster.execute(:command => "DROP ROLE \"#{new_resource.user}\"")
    end
  end
end

action_class do
  def cluster
    @cluster ||= OpenStreetMap::PostgreSQL.new(new_resource.cluster)
  end
end
