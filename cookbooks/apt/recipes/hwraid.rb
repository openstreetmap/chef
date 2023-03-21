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
                      "buster"
                    else
                      "precise"
                    end

apt_repository "hwraid" do
  uri "https://hwraid.le-vert.net/#{platform_name}"
  distribution distribution_name
  components ["main"]
  key "6005210E23B3D3B4"
end
