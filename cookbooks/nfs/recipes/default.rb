#
# Cookbook:: nfs
# Recipe:: default
#
# Copyright:: 2010, OpenStreetMap Foundation
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

package "nfs-common"

node[:nfs].each do |mountpoint, details|
  mount_options = if details[:readonly]
                    "ro,bg,soft,tcp,rsize=8192,wsize=8192,nfsvers=4"
                  else
                    "rw,bg,tcp,rsize=8192,wsize=8192,nfsvers=4"
                  end

  directory mountpoint do
    owner "root"
    group "root"
    mode "755"
    recursive true
    not_if { ::File.exist?(mountpoint) }
  end

  mount mountpoint do
    action [:mount, :enable]
    device "#{details[:host]}:#{details[:path]}"
    fstype "nfs"
    options mount_options
    ignore_failure true
  end
end
