# coding: utf-8
#
# Cookbook Name:: kibana
# Recipe:: default
#
# Copyright 2015, OpenStreetMap Foundation
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

require "yaml"

include_recipe "apache::ssl"

apache_module "proxy_http"

version = node[:kibana][:version]

remote_file "#{Chef::Config[:file_cache_path]}/kibana-#{version}.tar.gz" do
  source "https://download.elastic.co/kibana/kibana/kibana-4.1.1-linux-x64.tar.gz"
  not_if { File.exist?("/opt/kibana-#{version}/bin/kibana") }
end

directory "/opt/kibana-#{version}" do
  owner "root"
  group "root"
  mode 0o755
end

execute "unzip-kibana-#{version}" do
  command "tar --gunzip --extract --strip-components=1 --file=#{Chef::Config[:file_cache_path]}/kibana-#{version}.tar.gz"
  cwd "/opt/kibana-#{version}"
  user "root"
  group "root"
  not_if { File.exist?("/opt/kibana-#{version}/bin/kibana") }
end

directory "/etc/kibana" do
  owner "root"
  group "root"
  mode 0o755
end

directory "/var/run/kibana" do
  owner "kibana"
  group "kibana"
  mode 0o755
end

directory "/var/log/kibana" do
  owner "kibana"
  group "kibana"
  mode 0o755
end

systemd_service "kibana@" do
  description "Kibana server"
  after "network.target"
  user "kibana"
  exec_start "/opt/kibana-#{version}/bin/kibana -c /etc/kibana/%i.yml"
  restart "on-failure"
end

node[:kibana][:sites].each do |name, details|
  file "/etc/kibana/#{name}.yml" do
    content YAML.dump(YAML.safe_load(File.read("/opt/kibana-#{version}/config/kibana.yml")).merge(
                        "port" => details[:port],
                        "host" => "127.0.0.1",
                        "elasticsearch_url" => details[:elasticsearch_url],
                        "pid_file" => "/var/run/kibana/#{name}.pid",
                        "log_file" => "/var/log/kibana/#{name}.log"
    ))
    owner "root"
    group "root"
    mode 0o644
    notifies :restart, "service[kibana@#{name}]"
  end

  service "kibana@#{name}" do
    action [:enable, :start]
    supports :status => true, :restart => true, :reload => false
  end

  ssl_certificate details[:site] do
    domains details[:site]
    fallback_certificate "openstreetmap"
    notifies :reload, "service[apache2]"
  end

  apache_site details[:site] do
    template "apache.erb"
    variables details.merge(:passwd => "/etc/kibana/#{name}.passwd")
  end
end
