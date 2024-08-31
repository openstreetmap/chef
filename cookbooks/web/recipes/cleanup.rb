#
# Cookbook:: web
# Recipe:: cleanup
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

include_recipe "web::base"

web_passwords = data_bag_item("web", "passwords")

rails_directory = "#{node[:web][:base_directory]}/rails"

file "/etc/cron.daily/web-cleanup" do
  action :delete
end

systemd_service "rails-cleanup" do
  description "Rails cleanup"
  type "simple"
  environment "RAILS_ENV" => "production",
              "SECRET_KEY_BASE" => web_passwords["secret_key_base"]
  user "rails"
  working_directory rails_directory
  exec_start "#{node[:ruby][:bundle]} exec rails db:expire_tokens"
  sandbox :enable_network => true
  memory_deny_write_execute false
  read_write_paths "/var/log/web"
end

systemd_timer "rails-cleanup" do
  description "Rails cleanup"
  on_calendar "02:00"
end

service "rails-cleanup.timer" do
  action [:enable, :start]
end
