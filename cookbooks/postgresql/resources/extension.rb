#
# Cookbook:: postgresql
# Resource:: postgresql_extension
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

property :extension, :kind_of => String, :name_property => true
property :cluster, :kind_of => String, :required => true
property :database, :kind_of => String, :required => true

action :create do
  unless cluster.extensions(new_resource.database).include?(new_resource.extension)
    converge_by "create extension #{new_resource.extension}" do
      cluster.execute(:command => "CREATE EXTENSION #{new_resource.extension}", :database => new_resource.database)
    end
  end
end

action :drop do
  if cluster.extensions(new_resource.database).include?(new_resource.extension)
    converge_by "drop extension #{new_resource.extension}" do
      cluster.execute(:command => "DROP EXTENSION #{new_resource.extension}", :database => new_resource.database)
    end
  end
end

action_class do
  def cluster
    @cluster ||= OpenStreetMap::PostgreSQL.new(new_resource.cluster)
  end
end
