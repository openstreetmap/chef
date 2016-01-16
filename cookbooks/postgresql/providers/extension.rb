#
# Cookbook Name:: postgresql
# Provider:: postgresql_extension
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

  @current_resource = Chef::Resource::PostgresqlExtension.new(new_resource.name)
  @current_resource.extension(new_resource.extension)
  @current_resource.cluster(new_resource.cluster)
  @current_resource.database(new_resource.database)
  @current_resource
end

action :create do
  unless @pg.extensions(new_resource.database).include?(new_resource.extension)
    @pg.execute(:command => "CREATE EXTENSION #{new_resource.extension}", :database => new_resource.database)
    new_resource.updated_by_last_action(true)
  end
end

action :drop do
  if @pg.extensions(new_resource.database).include?(new_resource.extension)
    @pg.execute(:command => "DROP EXTENSION #{new_resource.extension}", :database => new_resource.database)
    new_resource.updated_by_last_action(true)
  end
end
