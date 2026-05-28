#
# Cookbook:: apt
# Recipe:: fullstaq-ruby
#
# Copyright:: 2025, Tom Hughes
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

if platform?("debian") && node[:platform_version].to_i >= 13
  # First remove the repo if the keyring is in the unsupported keybox database format
  # Use apt_repository to remove the repository to ensure apt update is triggered later
  apt_repository "fullstaq-ruby-remove" do
    action :remove
    name "fullstaq-ruby"
    only_if { ::File.exist?("/etc/apt/keyrings/fullstaq-ruby.gpg") && ::File.binread("/etc/apt/keyrings/fullstaq-ruby.gpg", 12)[8..11] == "KBXf" }
  end
end

apt_repository "fullstaq-ruby" do
  uri "https://apt.fullstaqruby.org"
  distribution "#{node[:platform]}-#{node[:platform_version]}"
  components ["main"]
  key "https://raw.githubusercontent.com/fullstaq-ruby/server-edition/main/fullstaq-ruby.asc"
end
