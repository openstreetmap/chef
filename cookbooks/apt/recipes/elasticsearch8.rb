#
# Cookbook:: apt
# Recipe:: elasticsearch8
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

apt_repository "elasticsearch8.x" do
  uri "https://artifacts.elastic.co/packages/8.x/apt"
  distribution "stable"
  components ["main"]
  key "https://artifacts.elastic.co/GPG-KEY-elasticsearch"
end

# Workaround v18.8.11 bug: https://github.com/chef/chef/issues/15214
if Chef::VERSION == "18.8.11"
  edit_resource(:file, "/etc/apt/keyrings/elasticsearch8.x.gpg") do
    action :create_if_missing
  end
end
