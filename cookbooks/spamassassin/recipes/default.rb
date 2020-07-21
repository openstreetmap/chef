#
# Cookbook:: spamassassin
# Recipe:: default
#
# Copyright:: 2011, OpenStreetMap Foundation
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

package "spamassassin"

service "spamassassin" do
  action [:enable, :start]
  supports :status => true, :restart => true, :reload => true
end

directory "/var/spool/spamassassin" do
  owner "debian-spamd"
  group "debian-spamd"
  mode "755"
end

template "/etc/default/spamassassin" do
  source "spamassassin.erb"
  owner "root"
  group "root"
  mode "644"
  notifies :restart, "service[spamassassin]"
end

trusted_networks = node[:exim][:relay_from_hosts]

if node[:exim][:smarthost_name]
  search(:node, "exim_smarthost_via:#{node[:exim][:smarthost_name]}\\:*").each do |host|
    trusted_networks |= host.ipaddresses(:role => :external)
  end
end

trusted_networks -= ["127.0.0.1", "::1"]

template "/etc/spamassassin/local.cf" do
  source "local.cf.erb"
  owner "root"
  group "root"
  mode "644"
  variables :trusted_networks => trusted_networks.sort
  notifies :restart, "service[spamassassin]"
end
