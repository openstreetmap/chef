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

include_recipe "apt::postgresql"
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

  standby_mode = settings[:standby_mode] || defaults[:standby_mode]
  primary_conninfo = settings[:primary_conninfo] || defaults[:primary_conninfo]

  passwords = if primary_conninfo
                data_bag_item(primary_conninfo[:passwords][:bag],
                              primary_conninfo[:passwords][:item])
              end

  template "/etc/postgresql/#{version}/main/postgresql.conf" do
    source "postgresql.conf.erb"
    owner "postgres"
    group "postgres"
    mode "644"
    variables :version => version,
              :defaults => defaults,
              :settings => settings,
              :primary_conninfo => primary_conninfo,
              :passwords => passwords
    notifies :reload, "service[postgresql]"
    only_if { ::Dir.exist?("/etc/postgresql/#{version}/main") }
  end

  template "/etc/postgresql/#{version}/main/pg_hba.conf" do
    source "pg_hba.conf.erb"
    owner "postgres"
    group "postgres"
    mode "640"
    variables :early_rules => settings[:early_authentication_rules] || defaults[:early_authentication_rules],
              :late_rules => settings[:late_authentication_rules] || defaults[:late_authentication_rules]
    notifies :reload, "service[postgresql]"
    only_if { ::Dir.exist?("/etc/postgresql/#{version}/main") }
  end

  template "/etc/postgresql/#{version}/main/pg_ident.conf" do
    source "pg_ident.conf.erb"
    owner "postgres"
    group "postgres"
    mode "640"
    variables :maps => settings[:user_name_maps] || defaults[:user_name_maps]
    notifies :reload, "service[postgresql]"
    only_if { ::Dir.exist?("/etc/postgresql/#{version}/main") }
  end

  link "/var/lib/postgresql/#{version}/main/server.crt" do
    to "/etc/ssl/certs/ssl-cert-snakeoil.pem"
    only_if { ::Dir.exist?("/var/lib/postgresql/#{version}/main") }
  end

  link "/var/lib/postgresql/#{version}/main/server.key" do
    to "/etc/ssl/private/ssl-cert-snakeoil.key"
    only_if { ::Dir.exist?("/var/lib/postgresql/#{version}/main") }
  end

  if standby_mode == "on"
    file "/var/lib/postgresql/#{version}/main/standby.signal" do
      owner "postgres"
      group "postgres"
      mode "640"
    end
  else
    file "/var/lib/postgresql/#{version}/main/standby.signal" do
      action :delete
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
passwords = data_bag_item("postgresql", "passwords")

clusters.each do |name, details|
  prometheus_suffix = name.tr("/", "-")
  prometheus_database = node[:postgresql][:monitor_database]

  postgresql_user "prometheus" do
    cluster name
    password passwords["prometheus"]
    roles "pg_monitor"
    not_if { ::File.exist?("/var/lib/postgresql/#{name}/standby.signal") }
  end

  prometheus_exporter "postgres" do
    port 10000 + details[:port].to_i
    service "postgres-#{prometheus_suffix}"
    labels "cluster" => name
    scrape_interval "1m"
    scrape_timeout "1m"
    options %w[
      --collector.database_wraparound
      --collector.long_running_transactions
      --collector.process_idle
      --collector.stat_activity_autovacuum
      --collector.stat_wal_receiver
      --collector.statio_user_indexes
    ]
    environment "DATA_SOURCE_NAME" => "postgres:///#{prometheus_database}?host=/run/postgresql&port=#{details[:port]}&user=prometheus&password=#{passwords['prometheus']}"
    restrict_address_families "AF_UNIX"
    subscribes :restart, "template[/etc/prometheus/exporters/postgres_queries.yml]"
  end

  if node[:postgresql][:monitor_queries]
    template "/etc/prometheus/exporters/sql_exporter.yml" do
      source "sql_exporter.yml.erb"
      owner "root"
      group "root"
      mode "644"
    end

    prometheus_exporter "sql" do
      port 20000 + details[:port].to_i
      service "sql-#{prometheus_suffix}"
      labels "cluster" => name
      scrape_interval "1m"
      scrape_timeout "1m"
      options "--config.file=/etc/prometheus/exporters/sql_exporter.yml"
      environment "SQLEXPORTER_TARGET_DSN" => "postgres://prometheus:#{passwords['prometheus']}@/run/postgresql:#{details[:port]}/#{prometheus_database}"
      restrict_address_families "AF_UNIX"
      subscribes :restart, "template[/etc/prometheus/exporters/sql_exporter.yml]"
    end
  else
    prometheus_exporter "sql" do
      action :delete
      service "sql-#{prometheus_suffix}"
    end

    file "/etc/prometheus/exporters/sql_exporter.yml" do
      action :delete
    end
  end
end
