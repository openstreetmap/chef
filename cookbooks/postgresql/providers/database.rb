#
# Cookbook Name:: postgresql
# Provider:: postgresql_database
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

def load_current_resource
  @pg = Chef::PostgreSQL.new(new_resource.cluster)

  @current_resource = Chef::Resource::PostgresqlDatabase.new(new_resource.name)
  @current_resource.database(new_resource.database)
  @current_resource.cluster(new_resource.cluster)
  if pg_database = @pg.databases[@current_resource.database]
    @current_resource.owner(pg_database[:owner])
    @current_resource.encoding(pg_database[:encoding])
    @current_resource.encoding(pg_database[:collate])
    @current_resource.encoding(pg_database[:ctype])
  end
  @current_resource
end

action :create do
  unless @pg.databases.include?(new_resource.database)
    @pg.execute(:command => "CREATE DATABASE #{new_resource.database} OWNER #{new_resource.owner} TEMPLATE template0 ENCODING '#{new_resource.encoding}' LC_COLLATE '#{new_resource.collation}' LC_CTYPE '#{new_resource.ctype}'")
    new_resource.updated_by_last_action(true)
  else
    if new_resource.owner != @current_resource.owner
      @pg.execute(:command => "ALTER DATABASE #{new_resource.database} OWNER TO #{new_resource.owner}")
      new_resource.updated_by_last_action(true)
    end
  end
end

action :drop do
  if @pg.databases.include?(new_resource.database)
    @pg.execute(:command => "DROP DATABASE #{new_resource.database}")
    new_resource.updated_by_last_action(true)
  end
end
