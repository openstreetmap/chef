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

unified_mode true

default_action :create

property :timer, String, :name_property => true
property :dropin, String
property :description, String
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

  if new_resource.dropin
    directory dropin_directory do
      owner "root"
      group "root"
      mode "755"
    end
  end

  template config_name do
    cookbook "systemd"
    source "timer.erb"
    owner "root"
    group "root"
    mode "644"
    variables timer_variables
    notifies :run, "execute[systemctl-reload]"
  end

  execute "systemctl-reload" do
    action :nothing
    command "systemctl daemon-reload"
    user "root"
    group "root"
  end
end

action :delete do
  file config_name do
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

action_class do
  def dropin_directory
    "/etc/systemd/system/#{new_resource.timer}.timer.d"
  end

  def config_name
    if new_resource.dropin
      "#{dropin_directory}/#{new_resource.dropin}.conf"
    else
      "/etc/systemd/system/#{new_resource.timer}.timer"
    end
  end
end
