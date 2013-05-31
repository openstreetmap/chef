#
# Cookbook Name:: postgresql
# Definition:: postgresql_munin
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

define :postgresql_munin, :action => :create do
  cluster = params[:cluster]
  suffix = cluster.tr("/", ":")
  database = params[:database]

  if node[:postgresql][:clusters] and node[:postgresql][:clusters][cluster]
    munin_plugin "postgres_cache_#{database}:#{suffix}" do
      action params[:action]
      target "postgres_cache_"
      conf "munin.erb"
      conf_cookbook "postgresql"
      conf_variables :port => node[:postgresql][:clusters][cluster][:port]
    end

    munin_plugin "postgres_connections_#{database}:#{suffix}" do
      action params[:action]
      target "postgres_connections_"
      conf "munin.erb"
      conf_cookbook "postgresql"
      conf_variables :port => node[:postgresql][:clusters][cluster][:port]
    end

    munin_plugin "postgres_locks_#{database}:#{suffix}" do
      action params[:action]
      target "postgres_locks_"
      conf "munin.erb"
      conf_cookbook "postgresql"
      conf_variables :port => node[:postgresql][:clusters][cluster][:port]
    end

    munin_plugin "postgres_querylength_#{database}:#{suffix}" do
      action params[:action]
      target "postgres_querylength_"
      conf "munin.erb"
      conf_cookbook "postgresql"
      conf_variables :port => node[:postgresql][:clusters][cluster][:port]
    end

    munin_plugin "postgres_scans_#{database}:#{suffix}" do
      action params[:action]
      target "postgres_scans_"
      conf "munin.erb"
      conf_cookbook "postgresql"
      conf_variables :port => node[:postgresql][:clusters][cluster][:port]
    end

    munin_plugin "postgres_size_#{database}:#{suffix}" do
      action params[:action]
      target "postgres_size_"
      conf "munin.erb"
      conf_cookbook "postgresql"
      conf_variables :port => node[:postgresql][:clusters][cluster][:port]
    end

    munin_plugin "postgres_transactions_#{database}:#{suffix}" do
      action params[:action]
      target "postgres_transactions_"
      conf "munin.erb"
      conf_cookbook "postgresql"
      conf_variables :port => node[:postgresql][:clusters][cluster][:port]
    end

    munin_plugin "postgres_tuples_#{database}:#{suffix}" do
      action params[:action]
      target "postgres_tuples_"
      conf "munin.erb"
      conf_cookbook "postgresql"
      conf_variables :port => node[:postgresql][:clusters][cluster][:port]
    end
  else
    log "Postgres cluster #{cluster} not found" do
      level :warn
    end
  end
end
