#
# Cookbook:: fastly
# Recipe:: default
#
# Copyright:: 2026, OpenStreetMap Foundation
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
  jq
]

cache_dir = Chef::Config[:file_cache_path]

fastly_version = "14.0.4"

fastly_arch = if arm?
                "arm64"
              else
                "amd64"
              end

remote_file "#{cache_dir}/fastly-#{fastly_version}.deb" do
  source "https://github.com/fastly/cli/releases/download/v#{fastly_version}/fastly_#{fastly_version}_linux_#{fastly_arch}.deb"
  owner "root"
  group "root"
  mode "644"
  backup false
end

dpkg_package "fastly" do
  source "#{cache_dir}/fastly-#{fastly_version}.deb"
  version fastly_version
end
