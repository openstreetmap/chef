default[:vectortile][:database][:cluster] = "16/main"
default[:vectortile][:database][:postgis] = "3"
default[:vectortile][:database][:nodes_store] = :flat
default[:vectortile][:serve][:threads] = node.cpu_cores
default[:vectortile][:serve][:mode] = :live
default[:vectortile][:replication][:url] = "https://osm-planet-eu-central-1.s3.dualstack.eu-central-1.amazonaws.com/planet/replication/minute"
default[:vectortile][:replication][:enabled] = true
default[:vectortile][:replication][:tileupdate] = true
default[:vectortile][:replication][:threads] = node.cpu_cores
default[:vectortile][:rerender][:lowzoom][:enabled] = true
default[:vectortile][:rerender][:lowzoom][:maxzoom] = 9

default[:vectortile][:tilekiln][:version] = "0.8.1"
default[:vectortile][:spirit][:version] = "033a4117ec3604e28824b3f3608f5d163ef1b450"
default[:vectortile][:themepark][:version] = "beb454cc56e88533fb398ab293489c4e91f4d42b"

default[:postgresql][:versions] |= [node[:vectortile][:database][:cluster].split("/").first]
default[:postgresql][:monitor_database] = "tiles"
# As an absolute worst case, the server might have the serving, update, and a manual generation process going on.
# Each of these connects to two databases, then we add more connections so 20% are unused and we're
# not tripping alarms.
default[:postgresql][:settings][:defaults][:max_connections] = (node.cpu_cores * 8 + 20).to_s
default[:accounts][:users][:tileupdate][:status] = :role
default[:accounts][:users][:tilekiln][:status] = :role
