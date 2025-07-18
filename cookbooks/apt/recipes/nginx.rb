#
# Cookbook:: apt
# Recipe:: nginx
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

platform_name = if platform?("debian")
                  "debian"
                else
                  "ubuntu"
                end

apt_repository "nginx" do
  uri "https://nginx.org/packages/#{platform_name}"
  components ["nginx"]
  key "https://nginx.org/keys/nginx_signing.key"
end
