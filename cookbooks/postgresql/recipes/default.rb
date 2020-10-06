#
# Cookbook:: postgresql
# Recipe:: default
#
# Copyright:: 2012, OpenStreetMap Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "apt"
include_recipe "munin"
include_recipe "prometheus"

package "locales-all"
package "postgresql-common"

node[:postgresql][:versions].each do |version|
  package "postgresql-#{version}"
  package "postgresql-client-#{version}"
  package "postgresql-contrib-#{version}"
  package "postgresql-server-dev-#{version}"

  defaults = node[:postgresql][:settings][:defaults] || {}
  settings = node[:postgresql][:settings][version] || {}

  template "/etc/postgresql/#{version}/main/postgresql.conf" do
    source "postgresql.conf.erb"
    owner "postgres"
    group "postgres"
    mode "644"
    variables :version => version, :defaults => defaults, :settings => settings
    notifies :reload, "service[postgresql]"
  end

  template "/etc/postgresql/#{version}/main/pg_hba.conf" do
    source "pg_hba.conf.erb"
    owner "postgres"
    group "postgres"
    mode "640"
    variables :early_rules => settings[:early_authentication_rules] || defaults[:early_authentication_rules],
              :late_rules => settings[:late_authentication_rules] || defaults[:late_authentication_rules]
    notifies :reload, "service[postgresql]"
  end

  template "/etc/postgresql/#{version}/main/pg_ident.conf" do
    source "pg_ident.conf.erb"
    owner "postgres"
    group "postgres"
    mode "640"
    variables :maps => settings[:user_name_maps] || defaults[:user_name_maps]
    notifies :reload, "service[postgresql]"
  end

  link "/var/lib/postgresql/#{version}/main/server.crt" do
    to "/etc/ssl/certs/ssl-cert-snakeoil.pem"
  end

  link "/var/lib/postgresql/#{version}/main/server.key" do
    to "/etc/ssl/private/ssl-cert-snakeoil.key"
  end

  standby_mode = settings[:standby_mode] || defaults[:standby_mode]
  primary_conninfo = settings[:primary_conninfo] || defaults[:primary_conninfo]
  restore_command = settings[:restore_command] || defaults[:restore_command]

  if restore_command || standby_mode == "on"
    passwords = if primary_conninfo
                  data_bag_item(primary_conninfo[:passwords][:bag],
                                primary_conninfo[:passwords][:item])
                end

    template "/var/lib/postgresql/#{version}/main/recovery.conf" do
      source "recovery.conf.erb"
      owner "postgres"
      group "postgres"
      mode "640"
      variables :standby_mode => standby_mode,
                :primary_conninfo => primary_conninfo,
                :restore_command => restore_command,
                :passwords => passwords
      notifies :reload, "service[postgresql]"
    end
  else
    template "/var/lib/postgresql/#{version}/main/recovery.conf" do
      action :delete
      notifies :reload, "service[postgresql]"
    end
  end
end

service "postgresql" do
  action [:enable, :start]
  supports :status => true, :restart => true, :reload => true
end

ohai_plugin "postgresql" do
  template "ohai.rb.erb"
end

package "pgtop"
package "libdbd-pg-perl"

clusters = node[:postgresql][:clusters] || []

clusters.each do |name, details|
  suffix = name.tr("/", ":")

  munin_plugin "postgres_bgwriter_#{suffix}" do
    target "postgres_bgwriter"
    conf "munin.erb"
    conf_variables :port => details[:port]
  end

  munin_plugin "postgres_checkpoints_#{suffix}" do
    target "postgres_checkpoints"
    conf "munin.erb"
    conf_variables :port => details[:port]
  end

  munin_plugin "postgres_connections_db_#{suffix}" do
    target "postgres_connections_db"
    conf "munin.erb"
    conf_variables :port => details[:port]
  end

  munin_plugin "postgres_users_#{suffix}" do
    target "postgres_users"
    conf "munin.erb"
    conf_variables :port => details[:port]
  end

  munin_plugin "postgres_xlog_#{suffix}" do
    target "postgres_xlog"
    conf "munin.erb"
    conf_variables :port => details[:port]
  end

  next unless File.exist?("/var/lib/postgresql/#{details[:version]}/main/recovery.conf")

  munin_plugin "postgres_replication_#{suffix}" do
    target "postgres_replication"
    conf "munin.erb"
    conf_variables :port => details[:port]
  end
end

ports = clusters.collect do |_, details|
  details[:port]
end

template "/etc/prometheus/exporters/postgres_queries.yml" do
  source "postgres_queries.yml.erb"
  owner "root"
  group "root"
  mode "644"
end

prometheus_exporter "postgres" do
  port 9187
  user "postgres"
  options "--extend.query-path=/etc/prometheus/exporters/postgres_queries.yml"
  environment "DATA_SOURCE_URI" => "postgres@:#{ports.join(',:')}/postgres?host=/run/postgresql",
              "PG_EXPORTER_AUTO_DISCOVER_DATABASES" => "true",
              "PG_EXPORTER_EXCLUDE_DATABASES" => "postgres,template0,template1"
  subscribes :restart, "template[/etc/prometheus/exporters/postgres_queries.yml]"
end
