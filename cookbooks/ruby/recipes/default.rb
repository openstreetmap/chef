#
# Cookbook:: ruby
# Recipe:: default
#
# Copyright:: 2022, OpenStreetMap Foundation
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

ruby_version = node[:ruby][:version]

package %W[
  ruby
  ruby#{ruby_version}
  ruby
  ruby#{ruby_version}-dev
]

gem_package "bundler#{ruby_version}-1" do
  package_name "bundler"
  version "~> 1.17.3"
  gem_binary node[:ruby][:gem]
  options "--format-executable"
end

gem_package "bundler#{ruby_version}-2" do
  package_name "bundler"
  version "~> 2.3.16"
  gem_binary node[:ruby][:gem]
  options "--format-executable"
end
