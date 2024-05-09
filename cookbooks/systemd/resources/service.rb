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

unified_mode true

default_action :create

property :service, String, :name_property => true
property :dropin, String
property :description, String
property :condition_path_exists, [String, Array]
property :condition_path_exists_glob, [String, Array]
property :after, [String, Array]
property :conflicts, [String, Array]
property :wants, [String, Array]
property :requires, [String, Array]
property :joins_namespace_of, [String, Array]
property :type, String, :is => %w[simple forking oneshot dbus notify idle]
property :notify_access, String, :is => %w[none main exec all]
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
property :dynamic_user, [true, false]
property :working_directory, String
property :umask, String
property :exec_start_pre, [String, Array]
property :exec_start, [String, Array]
property :exec_start_post, [String, Array]
property :exec_stop, [String, Array]
property :exec_stop_post, [String, Array]
property :exec_reload, String
property :runtime_max_sec, Integer
property :runtime_directory, String
property :runtime_directory_mode, Integer
property :runtime_directory_preserve, [true, false, String]
property :state_directory, String
property :state_directory_mode, Integer
property :cache_directory, String
property :cache_directory_mode, Integer
property :logs_directory, String
property :logs_directory_mode, Integer
property :configuration_directory, String
property :configuration_directory_mode, Integer
property :standard_input, String,
         :is => %w[null tty tty-force tty-fail socket]
property :standard_output, String,
         :is => %w[inherit null tty journal syslog kmsg journal+console syslog+console kmsg+console socket]
property :standard_error, String,
         :is => %w[inherit null tty journal syslog kmsg journal+console syslog+console kmsg+console socket]
property :success_exit_status, [Integer, String, Array]
property :restart, String,
         :is => %w[on-success on-failure on-abnormal on-watchdog on-abort always]
property :restart_sec, [Integer, String]
property :protect_proc, String,
         :is => %w[noaccess invisible ptraceable default]
property :proc_subset, String,
         :is => %w[all pid]
property :bind_paths, [String, Array]
property :bind_read_only_paths, [String, Array]
property :capability_bounding_set, [String, Array]
property :ambient_capabilities, [String, Array]
property :no_new_privileges, [true, false]
property :protect_system, [true, false, String]
property :protect_home, [true, false, String]
property :read_write_paths, [String, Array]
property :read_only_paths, [String, Array]
property :inaccessible_paths, [String, Array]
property :private_tmp, [true, false]
property :private_devices, [true, false]
property :private_network, [true, false]
property :private_ipc, [true, false]
property :private_users, [true, false]
property :protect_hostname, [true, false]
property :protect_clock, [true, false]
property :protect_kernel_tunables, [true, false]
property :protect_kernel_modules, [true, false]
property :protect_kernel_logs, [true, false]
property :protect_control_groups, [true, false]
property :restrict_address_families, [String, Array]
property :restrict_namespaces, [true, false, String, Array]
property :lock_personality, [true, false]
property :memory_deny_write_execute, [true, false]
property :restrict_realtime, [true, false]
property :restrict_suid_sgid, [true, false]
property :remove_ipc, [true, false]
property :system_call_filter, [String, Array]
property :system_call_architectures, [String, Array]
property :tasks_max, Integer
property :timeout_start_sec, Integer
property :timeout_stop_sec, Integer
property :timeout_abort_sec, Integer
property :timeout_sec, Integer
property :pid_file, String
property :nice, Integer
property :io_scheduling_class, [Integer, String]
property :io_scheduling_priority, Integer
property :kill_mode, String,
         :is => %w[control-group process mixed none]
property :sandbox, [true, false, Hash]

action :create do
  service_variables = new_resource.to_hash

  unless new_resource.dropin
    service_variables[:type] ||= "simple"
  end

  if new_resource.sandbox
    service_variables[:protect_proc] = "invisible" unless property_is_set?(:protect_proc)
    service_variables[:proc_subset] = "pid" unless property_is_set?(:proc_subset)
    service_variables[:capability_bounding_set] = [] unless property_is_set?(:capability_bounding_set)
    service_variables[:ambient_capabilities] = [] unless property_is_set?(:ambient_capabilities)
    service_variables[:no_new_privileges] = true unless property_is_set?(:no_new_privileges)
    service_variables[:protect_system] = "strict" unless property_is_set?(:protect_system)
    service_variables[:protect_home] = true unless property_is_set?(:protect_home)
    service_variables[:private_tmp] = true unless property_is_set?(:private_tmp)
    service_variables[:private_devices] = true unless property_is_set?(:private_devices)
    service_variables[:private_network] = true unless property_is_set?(:private_network)
    service_variables[:private_ipc] = true unless property_is_set?(:private_ipc)
    service_variables[:private_users] = true unless property_is_set?(:private_users)
    service_variables[:protect_hostname] = true unless property_is_set?(:protect_hostname)
    service_variables[:protect_clock] = true unless property_is_set?(:protect_clock)
    service_variables[:protect_kernel_tunables] = true unless property_is_set?(:protect_kernel_tunables)
    service_variables[:protect_kernel_modules] = true unless property_is_set?(:protect_kernel_modules)
    service_variables[:protect_kernel_logs] = true unless property_is_set?(:protect_kernel_logs)
    service_variables[:protect_control_groups] = true unless property_is_set?(:protect_control_groups)
    service_variables[:restrict_address_families] = [] unless property_is_set?(:restrict_address_families)
    service_variables[:restrict_namespaces] = true unless property_is_set?(:restrict_namespaces)
    service_variables[:lock_personality] = true unless property_is_set?(:lock_personality)
    service_variables[:memory_deny_write_execute] = true unless property_is_set?(:memory_deny_write_execute)
    service_variables[:restrict_realtime] = true unless property_is_set?(:restrict_realtime)
    service_variables[:restrict_suid_sgid] = true unless property_is_set?(:restrict_suid_sgid)
    service_variables[:remove_ipc] = true unless property_is_set?(:remove_ipc)
    service_variables[:system_call_filter] = "@system-service" unless property_is_set?(:system_call_filter)
    service_variables[:system_call_architectures] = "native" unless property_is_set?(:system_call_architectures)

    if sandbox_option(:enable_network)
      service_variables[:private_network] = false
      service_variables[:restrict_address_families] = Array(service_variables[:restrict_address_families]).append("AF_INET", "AF_INET6").reject { |f| f == "none" }
    end
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
  def sandbox_option(option)
    new_resource.sandbox[option] if new_resource.sandbox.is_a?(Hash)
  end

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
