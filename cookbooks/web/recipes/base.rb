#
# Cookbook:: web
# Recipe:: base
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

node.default[:nfs]["/store/rails"] = {
  :host => node[:web][:fileserver],
  :path => "/store/rails"
}

include_recipe "accounts"
include_recipe "nfs"

directory node[:web][:base_directory] do
  group "rails"
  mode "2775"
end

systemd_tmpfile node[:web][:pid_directory] do
  type "d"
  owner "rails"
  group "rails"
  mode "0755"
end

directory node[:web][:log_directory] do
  owner "rails"
  group "rails"
  mode "775"
end

template "/etc/logrotate.d/web" do
  source "logrotate.web.erb"
  owner "root"
  group "root"
  mode "644"
end
