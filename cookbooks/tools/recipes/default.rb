#
# Cookbook Name:: tools
# Recipe:: default
#
# Copyright 2011, OpenStreetMap Foundation
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

package "bash-completion"
package "dmidecode"
package "ethtool"
package "lsof"
package "lsscsi"
package "pciutils"
package "screen"
package "smartmontools"
package "strace"
package "sysstat"
package "tcpdump"
package "usbutils"
package "numactl"
package "xfsprogs"
package "sysv-rc-conf"
package "iotop"

if node[:lsb][:release].to_f <= 11.04
  package "lslk"
end

package "rsyslog"

service "rsyslog" do
  action [ :enable, :start ]
  supports :status => true, :restart => true, :reload => true
end

#Remove unused base package
package "mlocate" do
  action :purge
end

#Remove ubuntu "desktop" vestigal package
package "whoopsie" do
  action :purge
end

