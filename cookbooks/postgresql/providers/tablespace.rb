#
# Cookbook Name:: postgresql
# Provider:: postgresql_tablespace
#
# Copyright 2016, OpenStreetMap Foundation
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

  @current_resource = Chef::Resource::PostgresqlTablespace.new(new_resource.name)
  @current_resource.tablespace(new_resource.tablespace)
  @current_resource.location(new_resource.location)
  @current_resource
end

action :create do
  unless @pg.tablespaces.include?(new_resource.tablespace)
    @pg.execute(:command => "CREATE TABLESPACE #{new_resource.tablespace} LOCATION '#{new_resource.location}'")
    new_resource.updated_by_last_action(true)
  end
end

action :drop do
  if @pg.tablespaces.include?(new_resource.tablespace)
    @pg.execute(:command => "DROP TABLESPACE #{new_resource.tablespace}")
    new_resource.updated_by_last_action(true)
  end
end
