#
# Cookbook:: apt
# Recipe:: hwraid
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

distribution_name = if platform?("debian")
                      node[:lsb][:codename]
                    else
                      "precise"
                    end

if platform?("debian") && node[:platform_version].to_i >= 13
  # First remove the repo if the keyring is in the unsupported keybox database format
  # Use apt_repository to remove the repository to ensure apt update is triggered later
  apt_repository "hwraid-remove" do
    action :remove
    repo_name "hwraid"
    only_if { ::File.exist?("/etc/apt/keyrings/hwraid.gpg") && ::File.binread("/etc/apt/keyrings/hwraid.gpg", 12)[8..11] == "KBXf" }
  end
end

apt_repository "hwraid" do
  uri "https://hwraid.le-vert.net/#{platform_name}"
  distribution distribution_name
  components ["main"]
  key "https://hwraid.le-vert.net/debian/hwraid.le-vert.net.gpg.key"
end
