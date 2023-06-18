#
# Cookbook:: apt
# Recipe:: elasticsearch7
#
# Copyright:: 2022, Grant Slater
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

apt_repository "elasticsearch7.x" do
  uri "https://artifacts.elastic.co/packages/7.x/apt"
  distribution "stable"
  components ["main"]
  key "D27D666CD88E42B4"
end

# Workaround for mediawiki 1.39.x which ONLY supports elasticsearch 7.10.2
# elasticsearch 7.10.2 is the final Apache 2.0 licensed version of elasticsearch
apt_preference "elasticsearch" do
  pin          "version 7.10.2"
  pin_priority "1100"
end
