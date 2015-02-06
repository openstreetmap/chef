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

%w(
  bin_relay_log commands connections files_tables innodb_bpool
  innodb_bpool_act innodb_insert_buf innodb_io innodb_io_pend
  innodb_log innodb_rows innodb_semaphores innodb_tnx myisam_indexes
  network_traffic qcache qcache_mem replication select_types slow
  sorts table_locks tmp_tables
).each do |stat|
  munin_plugin "mysql_#{stat}" do
    target "mysql_"
  end
end
