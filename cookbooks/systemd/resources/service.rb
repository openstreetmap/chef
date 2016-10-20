#
# Cookbook Name:: systemd
# Resource:: systemd_service
#
# Copyright 2016, OpenStreetMap Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default_action :create

property :name, String
property :description, String, :required => true
property :after, [String, Array]
property :wants, [String, Array]
property :type, String,
         :default => "simple",
         :is => %w(simple forking oneshot dbus notify idle)
property :limit_nofile, Integer
property :environment, Hash, :default => {}
property :environment_file, [String, Hash]
property :user, String
property :group, String
property :exec_start_pre, String
property :exec_start, String, :required => true
property :exec_start_post, String
property :exec_stop, String
property :exec_reload, String
property :runtime_directory, String
property :runtime_directory_mode, Integer
property :standard_input, String,
         :is => %w(null tty tty-force tty-fail socket)
property :standard_output, String,
         :is => %w(inherit null tty journal syslog kmsg journal+console syslog+console kmsg+console socket)
property :standard_error, String,
         :is => %w(inherit null tty journal syslog kmsg journal+console syslog+console kmsg+console socket)
property :restart, String,
         :is => %w(on-success on-failure on-abnormal on-watchdog on-abort always)
property :private_tmp, [TrueClass, FalseClass]
property :private_devices, [TrueClass, FalseClass]
property :private_network, [TrueClass, FalseClass]
property :protect_system, [TrueClass, FalseClass, String]
property :protect_home, [TrueClass, FalseClass, String]
property :timeout_sec, Integer
property :pid_file, String

action :create do
  service_variables = new_resource.to_hash

  if environment_file.is_a?(Hash)
    template "/etc/default/#{name}" do
      cookbook "systemd"
      source "environment.erb"
      owner "root"
      group "root"
      mode 0o640
      variables :environment => environment_file
    end

    service_variables[:environment_file] = "/etc/default/#{name}"
  end

  template "/etc/systemd/system/#{name}.service" do
    cookbook "systemd"
    source "service.erb"
    owner "root"
    group "root"
    mode 0o644
    variables service_variables
  end

  execute "systemctl-reload-#{name}.service" do
    action :nothing
    command "systemctl daemon-reload"
    user "root"
    group "root"
    subscribes :run, "template[/etc/systemd/system/#{name}.service]"
  end
end

action :delete do
  file "/etc/default/#{name}" do
    action :delete
    only_if { environment_file.is_a?(Hash) }
  end

  file "/etc/systemd/system/#{name}.service" do
    action :delete
  end

  execute "systemctl-reload-#{name}.service" do
    action :nothing
    command "systemctl daemon-reload"
    user "root"
    group "root"
    subscribes :run, "file[/etc/systemd/system/#{name}.service]"
  end
end
