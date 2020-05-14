#
# Cookbook:: postgresql
# Resource:: postgresql_database
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

property :database, :kind_of => String, :name_property => true
property :cluster, :kind_of => String, :required => true
property :owner, :kind_of => String, :required => [:create]
property :encoding, :kind_of => String, :default => "UTF8"
property :collation, :kind_of => String, :default => "en_GB.UTF8"
property :ctype, :kind_of => String, :default => "en_GB.UTF8"

action :create do
  if !cluster.databases.include?(new_resource.database)
    converge_by "create database #{new_resource.database}" do
      cluster.execute(:command => "CREATE DATABASE \"#{new_resource.database}\" OWNER \"#{new_resource.owner}\" TEMPLATE template0 ENCODING '#{new_resource.encoding}' LC_COLLATE '#{new_resource.collation}' LC_CTYPE '#{new_resource.ctype}'")
    end
  elsif new_resource.owner != cluster.databases[new_resource.database][:owner]
    converge_by "alter database #{new_resource.database}" do
      cluster.execute(:command => "ALTER DATABASE \"#{new_resource.database}\" OWNER TO \"#{new_resource.owner}\"")
    end
  end
end

action :drop do
  if cluster.databases.include?(new_resource.database)
    converge_by "drop database #{new_resource.database}" do
      cluster.execute(:command => "DROP DATABASE \"#{new_resource.database}\"")
    end
  end
end

action_class do
  def cluster
    @cluster ||= OpenStreetMap::PostgreSQL.new(new_resource.cluster)
  end
end
