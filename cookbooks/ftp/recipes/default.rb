#
# Cookbook:: FTP
# Recipe:: default
#
# Copyright:: 2018, OpenStreetMap Foundation
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

package %w[
  vsftpd
  libpam-pwdfile
]

template "/etc/vsftpd.conf" do
  source "vsftpd.conf.erb"
  owner "root"
  group "root"
  mode "644"
end

template "/etc/pam.d/vsftpd" do
  source "pam-vsftpd.erb"
  owner "root"
  group "root"
  mode "644"
end

service "vsftpd" do
  action [:enable, :start]
  supports :status => true, :restart => true, :reload => true
  subscribes :restart, "template[/etc/vsftpd.conf]"
  subscribes :restart, "template[/etc/pam.d/vsftpd]"
end

firewall_rule "accept-ftp-tcp" do
  action :accept
  source "net"
  dest "fw"
  proto "tcp"
  dest_ports "ftp"
  source_ports "-"
  helper "ftp"
end
