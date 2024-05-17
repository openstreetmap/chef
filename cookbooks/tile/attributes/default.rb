default[:tile][:database][:cluster] = "14/main"
default[:tile][:database][:postgis] = "3"
default[:tile][:database][:node_file] = "/store/database/nodes"
default[:tile][:database][:multi_geometry] = true
default[:tile][:database][:hstore] = true
default[:tile][:database][:style_file] = nil
default[:tile][:database][:tag_transform_script] = nil

default[:tile][:mapnik] = "3.1"

default[:tile][:replication][:directory] = "/var/lib/replicate"
default[:tile][:replication][:url] = "https://osm-planet-eu-central-1.s3.dualstack.eu-central-1.amazonaws.com/planet/replication/minute"

default[:tile][:data] = {}
default[:tile][:styles] = {}

default[:postgresql][:versions] |= [node[:tile][:database][:cluster].split("/").first]
default[:postgresql][:monitor_database] = "gis"

default[:accounts][:users][:tile][:status] = :role

default[:apache][:event][:server_limit] = node.cpu_cores * 5 / 4
default[:apache][:event][:max_request_workers] = node.cpu_cores * node[:apache][:event][:threads_per_child]
default[:apache][:event][:max_spare_threads] = node.cpu_cores * node[:apache][:event][:threads_per_child]
