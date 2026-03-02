#
# Cookbook:: planet
# Recipe:: user
#
# Copyright:: 2026, OpenStreetMap Foundation
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

group "planet" do
  gid 502
  append true
end

user "planet" do
  uid 502
  gid 502
  comment "planet.openstreetmap.org"
  home "/home/planet"
  shell "/usr/sbin/nologin"
  manage_home true
end
