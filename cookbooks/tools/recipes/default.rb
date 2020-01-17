#
# Cookbook:: tools
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

package %w[
  bash-completion
  dmidecode
  ethtool
  lsof
  lsscsi
  pciutils
  screen
  smartmontools
  strace
  sysstat
  tcpdump
  usbutils
  numactl
  xfsprogs
  iotop
  lvm2
  rsyslog
  cron
]

service "rsyslog" do
  action [:enable, :start]
  supports :status => true, :restart => true, :reload => true
end

# Remove some unused and unwanted packages
package %w[mlocate nano whoopsie] do
  action :purge
end

# Remove screen-cleanup left behind by old release.
link "/etc/init.d/screen-cleanup" do
  action :delete
end

# Cleanup unused file
file "/etc/systemd/system/cron.service.d/chef.conf" do
  action :delete
end

# Configure cron to run in the local timezone of the machine
systemd_service "cron-timezone" do
  service "cron"
  dropin "timezone"
  environment "TZ" => node[:timezone]
  notifies :restart, "service[cron]"
  only_if { node[:timezone] }
end

# Make sure cron is running
service "cron" do
  action [:enable, :start]
end
