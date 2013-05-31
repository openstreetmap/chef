#
# Cookbook Name:: openvpn
# Recipe:: default
#
# Copyright 2012, OpenStreetMap Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

package "openvpn"

service "openvpn" do
  action [ :enable, :start ]
  supports :status => true, :restart => true, :reload => true
  ignore_failure true
end

node[:openvpn][:tunnels].each do |name,details|
  if peer = search(:node, "fqdn:#{details[:peer][:host]}").first
    if peer[:openvpn] and not details[:peer][:address]
      node.default[:openvpn][:tunnels][name][:peer][:address] = peer[:openvpn][:address]
    end

    node.default[:openvpn][:tunnels][name][:peer][:networks] = peer.interfaces(:role => :internal).collect do |interface|
      { :address => interface[:network], :netmask => interface[:netmask] }
    end
  else
    node.default[:openvpn][:tunnels][name][:peer][:networks] = []
  end

  if details[:mode] == "client"
    execute "openvpn-genkey-#{name}" do
      command "openvpn --genkey --secret /etc/openvpn/#{name}.key"
      user "root"
      group "root"
      creates "/etc/openvpn/#{name}.key"
    end

    if File.exists?("/etc/openvpn/#{name}.key")
      node.set[:openvpn][:keys][name] = IO.read("/etc/openvpn/#{name}.key")
    end
  elsif peer and peer[:openvpn]
    file "/etc/openvpn/#{name}.key" do
      owner "root"
      group "root"
      mode 0600
      content peer[:openvpn][:keys][name]
    end
  end

  if node[:openvpn][:tunnels][name][:peer][:address]
    template "/etc/openvpn/#{name}.conf" do
      source "tunnel.conf.erb"
      owner "root"
      group "root"
      mode 0644
      variables :name => name,
      :address => node[:openvpn][:address],
      :port => node[:openvpn][:tunnels][name][:port],
      :mode => node[:openvpn][:tunnels][name][:mode],
      :peer => node[:openvpn][:tunnels][name][:peer]
      notifies :restart, resources(:service => "openvpn")
    end
  else
    file "/etc/openvpn/#{name}.conf" do
      action :delete
    end
  end
end
