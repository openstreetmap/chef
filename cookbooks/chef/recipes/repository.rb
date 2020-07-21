#
# Cookbook:: chef
# Recipe:: repository
#
# Copyright:: 2013, OpenStreetMap Foundation
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

include_recipe "git"

keys = data_bag_item("chef", "keys")

chef_gem "bundler" do
  version ">= 2.1.4"
end

directory "/var/lib/chef" do
  owner "chefrepo"
  group "chefrepo"
  mode "2775"
end

%w[public private].each do |repository|
  repository_directory = node[:chef][:"#{repository}_repository"]

  git "/var/lib/chef/#{repository}" do
    action :checkout
    repository repository_directory
    revision "master"
    user "chefrepo"
    group "chefrepo"
  end

  directory "/var/lib/chef/#{repository}/.chef" do
    owner "chefrepo"
    group "chefrepo"
    mode "2775"
  end

  file "/var/lib/chef/#{repository}/.chef/client.pem" do
    content keys["git"].join("\n")
    owner "chefrepo"
    group "chefrepo"
    mode "660"
  end

  cookbook_file "/var/lib/chef/#{repository}/.chef/knife.rb" do
    source "knife.rb"
    owner "chefrepo"
    group "chefrepo"
    mode "660"
  end

  template "#{repository_directory}/hooks/post-receive" do
    source "post-receive.erb"
    owner "chefrepo"
    group "chefrepo"
    mode "750"
    variables :repository => repository
  end
end
