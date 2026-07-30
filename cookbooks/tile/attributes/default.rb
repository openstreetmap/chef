default[:tile][:database][:cluster] = "18/main"
default[:tile][:database][:postgis] = "3"
default[:tile][:database][:node_file] = "/store/database/nodes"

if node.platform?("debian") && node[:lsb][:release].to_f > 12
  default[:tile][:mapnik] = "4.0"
  default[:tile][:mapnik_plugins_dir] = "#{node[:systemd_paths][:"system-library-arch"]}/mapnik/4.0/input"
else
  default[:tile][:mapnik] = "3.1"
  default[:tile][:mapnik_plugins_dir] = "/usr/lib/mapnik/3.1/input"
end

default[:tile][:replication][:directory] = "/var/lib/replicate"
default[:tile][:replication][:url] = "https://osm-planet-eu-central-1.s3.dualstack.eu-central-1.amazonaws.com/planet/replication/minute"

default[:tile][:data] = {}
default[:tile][:styles] = {}

default[:postgresql][:versions] |= [node[:tile][:database][:cluster].split("/").first]
default[:postgresql][:monitor_database] = "gis"

default[:apache][:event][:server_limit] = node.cpu_cores * 5 / 4
default[:apache][:event][:max_request_workers] = node.cpu_cores * node[:apache][:event][:threads_per_child]
default[:apache][:event][:max_spare_threads] = node.cpu_cores * node[:apache][:event][:threads_per_child]
