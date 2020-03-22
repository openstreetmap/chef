#
# Cookbook:: docker
# Recipe:: default
#
# Copyright:: 2020, OpenStreetMap Foundation
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
  apt-transport-https
  ca-certificates
  curl
  software-properties-common
  gnupg2
]

template "/etc/docker/daemon.json" do
  source "daemon.json.erb"
  owner "root"
  group "root"
  mode 0o644
end

package %w[
  docker-ce
  docker-ce-cli
  containerd.io
]

service "docker" do
  action [:enable, :start]
  subscribes :restart, "template[/etc/docker/daemon.json]"
end
