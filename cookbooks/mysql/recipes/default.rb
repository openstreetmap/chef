#
# Cookbook Name:: mysql
# Recipe:: default
#
# Copyright 2013, OpenStreetMap Foundation
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

package "mysql-server"
package "mysql-client"

service "mysql" do
  action [:enable, :start]
  supports :status => true, :restart => true, :reload => true
end

template "/etc/mysql/conf.d/chef.cnf" do
  source "my.cnf.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :reload, "service[mysql]"
end

package "libdbd-mysql-perl"
package "libcache-cache-perl"

munin_plugin "mysql_bin_relay_log" do
  target "mysql_"
end

munin_plugin "mysql_commands" do
  target "mysql_"
end

munin_plugin "mysql_connections" do
  target "mysql_"
end

munin_plugin "mysql_files_tables" do
  target "mysql_"
end

munin_plugin "mysql_innodb_bpool" do
  target "mysql_"
end

munin_plugin "mysql_innodb_bpool_act" do
  target "mysql_"
end

munin_plugin "mysql_innodb_insert_buf" do
  target "mysql_"
end

munin_plugin "mysql_innodb_io" do
  target "mysql_"
end

munin_plugin "mysql_innodb_io_pend" do
  target "mysql_"
end

munin_plugin "mysql_innodb_log" do
  target "mysql_"
end

munin_plugin "mysql_innodb_rows" do
  target "mysql_"
end

munin_plugin "mysql_innodb_semaphores" do
  target "mysql_"
end

munin_plugin "mysql_innodb_tnx" do
  target "mysql_"
end

munin_plugin "mysql_myisam_indexes" do
  target "mysql_"
end

munin_plugin "mysql_network_traffic" do
  target "mysql_"
end

munin_plugin "mysql_qcache" do
  target "mysql_"
end

munin_plugin "mysql_qcache_mem" do
  target "mysql_"
end

munin_plugin "mysql_replication" do
  target "mysql_"
end

munin_plugin "mysql_select_types" do
  target "mysql_"
end

munin_plugin "mysql_slow" do
  target "mysql_"
end

munin_plugin "mysql_sorts" do
  target "mysql_"
end

munin_plugin "mysql_table_locks" do
  target "mysql_"
end

munin_plugin "mysql_tmp_tables" do
  target "mysql_"
end
