#
# Cookbook:: prometheus
# Recipe:: smokeping
#
# Copyright:: 2023, OpenStreetMap Foundation
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

include_recipe "prometheus"

hosts = {}

%w[ipv4 ipv6].each do |protocol|
  json_file = "#{Chef::Config[:file_cache_path]}/#{protocol}.json"

  remote_file json_file do
    source "https://dns.openstreetmap.org/#{protocol}.json"
    compile_time true
    ignore_failure true
  end

  hosts[protocol] = if File.exist?(json_file)
                      JSON.parse(IO.read(json_file)).filter_map do |name, address|
                        name unless name.split(".").first == node[:hostname] ||
                                    name.end_with?(".oob") ||
                                    address.start_with?("10.")
                      end
                    else
                      []
                    end
end

template "/etc/prometheus/exporters/smokeping.yml" do
  source "smokeping.yml.erb"
  owner "root"
  group "root"
  mode "644"
  variables :ip4_hosts => hosts["ipv4"], :ip6_hosts => hosts["ipv6"]
end

prometheus_exporter "smokeping" do
  port 9374
  environment "GOMAXPROCS" => "1"
  options "--config.file=/etc/prometheus/exporters/smokeping.yml"
  capability_bounding_set "CAP_NET_RAW"
  ambient_capabilities "CAP_NET_RAW"
  private_users false
  subscribes :restart, "template[/etc/prometheus/exporters/smokeping.yml]"
end
