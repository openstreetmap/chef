#
# Cookbook:: apt
# Recipe:: yarn
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

apt_repository "yarn" do
  uri "https://dl.yarnpkg.com/debian"
  distribution "stable"
  components ["main"]
  key "https://dl.yarnpkg.com/debian/pubkey.gpg"
end

# Workaround v18.8.11 bug: https://github.com/chef/chef/issues/15214
if Chef::VERSION == "18.8.11"
  edit_resource(:file, "/etc/apt/keyrings/yarn.gpg") do
    action :create_if_missing
  end
end
