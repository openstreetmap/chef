#
# Cookbook:: apt
# Recipe:: grafana
#
# Copyright:: 2022, Tom Hughes
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

include_recipe "apt"

remote_file "/etc/apt/trusted.gpg.d/grafana.asc" do
  source "https://packages.grafana.com/gpg.key"
  owner "root"
  group "root"
  mode "644"
end

apt_repository "grafana" do
  uri "https://packages.grafana.com/enterprise/deb"
  distribution "stable"
  components ["main"]
end
