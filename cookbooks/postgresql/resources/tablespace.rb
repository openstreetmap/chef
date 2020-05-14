#
# Cookbook:: postgresql
# Resource:: postgresql_tablespace
#
# Copyright:: 2016, OpenStreetMap Foundation
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

property :tablespace, :kind_of => String, :name_property => true
property :cluster, :kind_of => String, :required => true
property :location, :kind_of => String, :required => [:create]

action :create do
  unless cluster.tablespaces.include?(new_resource.tablespace)
    converge_by "create tablespace #{new_resource.tablespace}" do
      cluster.execute(:command => "CREATE TABLESPACE #{new_resource.tablespace} LOCATION '#{new_resource.location}'")
    end
  end
end

action :drop do
  if cluster.tablespaces.include?(new_resource.tablespace)
    converge_by "drop tablespace #{new_resource.tablespace}" do
      cluster.execute(:command => "DROP TABLESPACE #{new_resource.tablespace}")
    end
  end
end

action_class do
  def cluster
    @cluster ||= OpenStreetMap::PostgreSQL.new(new_resource.cluster)
  end
end
