#
# Cookbook:: systemd
# Resource:: systemd_timer
#
# Copyright:: 2019, OpenStreetMap Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default_action :create

property :timer, String, :name_property => true
property :description, String, :required => [:create]
property :after, [String, Array]
property :wants, [String, Array]
property :on_active_sec, [Integer, String]
property :on_boot_sec, [Integer, String]
property :on_startup_sec, [Integer, String]
property :on_unit_active_sec, [Integer, String]
property :on_unit_inactive_sec, [Integer, String]
property :on_calendar, String
property :accuracy_sec, [Integer, String]
property :randomized_delay_sec, [Integer, String]
property :unit, String
property :persistent, [true, false]
property :wake_system, [true, false]
property :remain_after_elapse, [true, false]

action :create do
  timer_variables = new_resource.to_hash

  template "/etc/systemd/system/#{new_resource.timer}.timer" do
    cookbook "systemd"
    source "timer.erb"
    owner "root"
    group "root"
    mode "644"
    variables timer_variables
  end

  execute "systemctl-reload-#{new_resource.timer}.timer" do
    action :nothing
    command "systemctl daemon-reload"
    user "root"
    group "root"
    subscribes :run, "template[/etc/systemd/system/#{new_resource.timer}.timer]"
  end
end

action :delete do
  file "/etc/systemd/system/#{new_resource.timer}.timer" do
    action :delete
  end

  execute "systemctl-reload-#{new_resource.timer}.timer" do
    action :nothing
    command "systemctl daemon-reload"
    user "root"
    group "root"
    subscribes :run, "file[/etc/systemd/system/#{new_resource.timer}.timer]"
  end
end
