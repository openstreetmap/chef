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

uris = clusters.collect do |_, details|
  "postgres@:#{details[:port]}/postgres?host=/run/postgresql"
end

template "/etc/prometheus/exporters/postgres_queries.yml" do
  source "postgres_queries.yml.erb"
  owner "root"
  group "root"
  mode "644"
end

prometheus_exporter "postgres" do
  port 9187
  scrape_interval "1m"
  scrape_timeout "1m"
  user "postgres"
  options "--extend.query-path=/etc/prometheus/exporters/postgres_queries.yml"
  environment "DATA_SOURCE_URI" => uris.sort.uniq.first,
              "PG_EXPORTER_AUTO_DISCOVER_DATABASES" => "true",
              "PG_EXPORTER_EXCLUDE_DATABASES" => "postgres,template0,template1"
  restrict_address_families "AF_UNIX"
  remove_ipc false
  subscribes :restart, "template[/etc/prometheus/exporters/postgres_queries.yml]"
end
