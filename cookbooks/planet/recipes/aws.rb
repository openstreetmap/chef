#
# Cookbook:: planet
# Recipe:: aws
#
# Copyright:: 2023, OpenStreetMap Foundation
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

include_recipe "accounts"
include_recipe "awscli"

aws_credentials = data_bag_item("planet", "aws")

directory "/home/planet/.aws" do
  owner "planet"
  group "planet"
  mode "0755"
end

template "/home/planet/.aws/config" do
  source "aws-config.erb"
  owner "planet"
  group "planet"
  mode "0644"
end

template "/home/planet/.aws/credentials" do
  source "aws-credentials.erb"
  owner "planet"
  group "planet"
  mode "0600"
  variables :credentials => aws_credentials
end
