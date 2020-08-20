#
# Cookbook:: systemd
# Resource:: systemd_service
#
# Copyright:: 2016, OpenStreetMap Foundation
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

property :service, String, :name_property => true
property :dropin, String
property :description, String
property :after, [String, Array]
property :wants, [String, Array]
property :type, String, :is => %w[simple forking oneshot dbus notify idle]
property :limit_nofile, Integer
property :limit_as, [Integer, String]
property :limit_cpu, [Integer, String]
property :memory_low, [Integer, String]
property :memory_high, [Integer, String]
property :memory_max, [Integer, String]
property :environment, Hash, :default => {}
property :environment_file, [String, Hash]
property :user, String
property :group, String
property :working_directory, String
property :exec_start_pre, String
property :exec_start, String
property :exec_start_post, String
property :exec_stop, String
property :exec_reload, String
property :runtime_directory, String
property :runtime_directory_mode, Integer
property :standard_input, String,
         :is => %w[null tty tty-force tty-fail socket]
property :standard_output, String,
         :is => %w[inherit null tty journal syslog kmsg journal+console syslog+console kmsg+console socket]
property :standard_error, String,
         :is => %w[inherit null tty journal syslog kmsg journal+console syslog+console kmsg+console socket]
property :success_exit_status, [Integer, String, Array]
property :restart, String,
         :is => %w[on-success on-failure on-abnormal on-watchdog on-abort always]
property :private_tmp, [true, false]
property :private_devices, [true, false]
property :private_network, [true, false]
property :protect_system, [TrueClass, FalseClass, String]
property :protect_home, [TrueClass, FalseClass, String]
property :read_write_paths, [String, Array]
property :read_only_paths, [String, Array]
property :inaccessible_paths, [String, Array]
property :restrict_address_families, [String, Array]
property :no_new_privileges, [true, false]
property :tasks_max, Integer
property :timeout_sec, Integer
property :pid_file, String
property :nice, Integer
property :io_scheduling_class, [Integer, String]
property :io_scheduling_priority, Integer
property :kill_mode, String,
         :is => %w[control-group process mixed none]

action :create do
  service_variables = new_resource.to_hash

  unless new_resource.dropin
    service_variables[:type] ||= "simple"
  end

  if new_resource.environment_file.is_a?(Hash)
    template "/etc/default/#{new_resource.service}" do
      cookbook "systemd"
      source "environment.erb"
      owner "root"
      group "root"
      mode "640"
      variables :environment => new_resource.environment_file
    end

    service_variables[:environment_file] = "/etc/default/#{new_resource.service}"
  end

  if new_resource.dropin
    directory dropin_directory do
      owner "root"
      group "root"
      mode "755"
    end
  end

  template config_name do
    cookbook "systemd"
    source "service.erb"
    owner "root"
    group "root"
    mode "644"
    variables service_variables
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
  file "/etc/default/#{new_resource.service}" do
    action :delete
    only_if { new_resource.environment_file.is_a?(Hash) }
  end

  file config_name do
    action :delete
    notifies :run, "execute[systemctl-reload]"
  end

  execute "systemctl-reload" do
    action :nothing
    command "systemctl daemon-reload"
    user "root"
    group "root"
  end
end

action_class do
  def dropin_directory
    "/etc/systemd/system/#{new_resource.service}.service.d"
  end

  def config_name
    if new_resource.dropin
      "#{dropin_directory}/#{new_resource.dropin}.conf"
    else
      "/etc/systemd/system/#{new_resource.service}.service"
    end
  end
end
