#
# Cookbook:: systemd
# Resource:: systemd_socket
#
# Copyright:: 2021, OpenStreetMap Foundation
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

property :socket, String, :name_property => true
property :description, String, :required => [:create]
property :after, [String, Array]
property :wants, [String, Array]
property :listen_stream, [String, Array]
property :listen_datagram, [String, Array]
property :listen_sequential_packet, [String, Array]
property :listen_fifo, [String, Array]
property :listen_special, [String, Array]
property :listen_netlink, [String, Array]
property :listen_message_queue, [String, Array]
property :listen_usb_function, [String, Array]
property :socket_protocol, String
property :bind_ipv6_only, String
property :backlog, Integer
property :bind_to_device, String
property :socket_user, String
property :socket_group, String
property :socket_mode, Integer
property :directory_mode, Integer
property :accept, [true, false]
property :writable, [true, false]
property :max_connections, Integer
property :max_connections_per_source, Integer
property :keep_alive, [true, false]
property :keep_alive_time_sec, Integer
property :keep_alive_interval_sec, Integer
property :keep_alive_probes, Integer
property :no_delay, [true, false]
property :priority, Integer
property :defer_accept_sec, Integer
property :receive_buffer, Integer
property :send_buffer, Integer
property :ip_tos, Integer
property :ip_ttl, Integer
property :mark, Integer
property :reuse_port, [true, false]
property :pipe_size, Integer
property :message_queue_max_messages, Integer
property :message_queue_message_size, Integer
property :free_bind, [true, false]
property :transparent, [true, false]
property :broadcast, [true, false]
property :pass_credentials, [true, false]
property :pass_security, [true, false]
property :tcp_congestion, String
property :exec_start_pre, [String, Array]
property :exec_start, [String, Array]
property :exec_start_post, [String, Array]
property :exec_stop, [String, Array]
property :timeout_sec, [Integer, String]
property :service, String
property :remove_on_stop, [true, false]
property :symlinks, [String, Array]
property :file_descriptor_name, String
property :trigger_limit_interval_sec, [Integer, String]
property :trigger_limit_burst, Integer

action :create do
  socket_variables = new_resource.to_hash

  template "/etc/systemd/system/#{new_resource.socket}.socket" do
    cookbook "systemd"
    source "socket.erb"
    owner "root"
    group "root"
    mode "644"
    variables socket_variables
  end

  execute "systemctl-reload-#{new_resource.socket}.socket" do
    action :nothing
    command "systemctl daemon-reload"
    user "root"
    group "root"
    subscribes :run, "template[/etc/systemd/system/#{new_resource.socket}.socket]"
  end
end

action :delete do
  file "/etc/systemd/system/#{new_resource.socket}.socket" do
    action :delete
  end

  execute "systemctl-reload-#{new_resource.socket}.socket" do
    action :nothing
    command "systemctl daemon-reload"
    user "root"
    group "root"
    subscribes :run, "file[/etc/systemd/system/#{new_resource.socket}.socket]"
  end
end
