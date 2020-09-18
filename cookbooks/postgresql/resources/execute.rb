#
# Cookbook:: postgresql
# Resource:: postgresql_execute
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

default_action :run

property :command, :kind_of => String, :name_property => true
property :cluster, :kind_of => String, :required => true
property :database, :kind_of => String, :required => true
property :user, :kind_of => String, :default => "postgres"
property :group, :kind_of => String, :default => "postgres"

action :run do
  options = { :database => new_resource.database, :user => new_resource.user, :group => new_resource.group }

  converge_by "execute #{new_resource.command}" do
    if ::File.exist?(new_resource.command)
      cluster.execute(options.merge(:file => new_resource.command))
    else
      cluster.execute(options.merge(:command => new_resource.command))
    end
  end
end

action_class do
  def cluster
    @cluster ||= OpenStreetMap::PostgreSQL.new(new_resource.cluster)
  end
end
