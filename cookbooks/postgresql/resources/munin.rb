#
# Cookbook:: postgresql
# Resource:: postgresql_munin
#
# Copyright:: 2015, OpenStreetMap Foundation
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

property :munin, :kind_of => String, :name_property => true
property :cluster, :kind_of => String, :required => true
property :database, :kind_of => String, :required => true

action :create do
  cluster = node[:postgresql][:clusters] && node[:postgresql][:clusters][new_resource.cluster]
  database = new_resource.database

  if cluster
    %w[cache connections locks querylength scans size transactions tuples].each do |plugin|
      munin_plugin "postgres_#{plugin}_#{database}:#{suffix}" do
        target "postgres_#{plugin}_"
        conf "munin.erb"
        conf_cookbook "postgresql"
        conf_variables :port => cluster[:port]
        restart_munin false
      end
    end
  else
    Chef::Log.info "Postgres cluster #{new_resource.cluster} not found"
  end
end

action :delete do
  database = new_resource.database

  %w[cache connections locks querylength scans size transactions tuples].each do |plugin|
    munin_plugin "postgres_#{plugin}_#{database}:#{suffix}" do
      action :delete
      restart_munin false
    end
  end
end

action_class do
  def suffix
    new_resource.cluster.tr("/", ":")
  end
end

def after_created
  notifies :restart, "service[munin-node]"
end
