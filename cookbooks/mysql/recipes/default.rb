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
  supports :status => true, :restart => true
end

conf_file = if node[:lsb][:release].to_f >= 16.04
              "/etc/mysql/mysql.conf.d/zzz-chef.cnf"
            else
              "/etc/mysql/conf.d/zzz-chef.cnf"
            end

template conf_file do
  source "my.cnf.erb"
  owner "root"
  group "root"
  mode 0o644
  notifies :restart, "service[mysql]"
end

package "libdbd-mysql-perl"
package "libcache-cache-perl"

%w(
  commands connections files handler_read handler_tmp handler_transaction
  handler_write innodb_bpool innodb_bpool_act innodb_history_list_length
  innodb_insert_buf innodb_io innodb_io_pend innodb_log innodb_queries
  innodb_read_views innodb_rows innodb_semaphores innodb_srv_master_thread
  innodb_tnx max_mem mrr myisam_indexes network_traffic performance
  qcache qcache_mem select_types slow sorts table_definitions table_locks
  tmp_tables
).each do |stat|
  munin_plugin "mysql_#{stat}" do
    target "mysql_"
  end
end

%w(
  bin_relay_log files_tables replication
).each do |stat|
  munin_plugin "mysql_#{stat}" do
    action :delete
  end
end
