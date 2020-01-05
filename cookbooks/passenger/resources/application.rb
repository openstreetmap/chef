#
# Cookbook:: passenger
# Resource:: application
#
# Copyright:: 2018, OpenStreetMap Foundation
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

default_action :restart

property :application, String, :name_property => true

action :restart do
  execute new_resource.application do
    action :run
    command "passenger-config restart-app --ignore-app-not-running --ignore-passenger-not-running #{new_resource.application}"
    environment "PASSENGER_INSTANCE_REGISTRY_DIR" => node[:passenger][:instance_registry_dir]
    user "root"
    group "root"
  end
end
