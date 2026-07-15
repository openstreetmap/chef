default[:vectortile][:database][:cluster] = "18/main"
default[:vectortile][:database][:postgis] = "3"
default[:vectortile][:database][:nodes_store] = :flat
default[:vectortile][:serve][:threads] = node.cpu_cores
default[:vectortile][:serve][:mode] = :live
default[:vectortile][:replication][:url] = "https://osm-planet-eu-central-1.s3.dualstack.eu-central-1.amazonaws.com/planet/replication/minute"
default[:vectortile][:replication][:enabled] = true
default[:vectortile][:replication][:tileupdate] = true
default[:vectortile][:replication][:threads] = [0.5 * node.cpu_cores, 2].max.ceil
default[:vectortile][:rerender][:lowzoom][:enabled] = true
default[:vectortile][:rerender][:lowzoom][:threads] = [0.5 * node.cpu_cores, 2].max.ceil
default[:vectortile][:rerender][:lowzoom][:maxzoom] = 9
default[:vectortile][:ocean][:enabled] = true
default[:vectortile][:ocean][:threads] = [0.5 * node.cpu_cores, 2].max.ceil
default[:vectortile][:ocean][:tileupdate] = true

default[:vectortile][:tilekiln][:version] = "0.8.2"
default[:vectortile][:spirit][:version] = "7e49795de3ae2ad476da7a4a1f3208ae9a7a08e0"
default[:vectortile][:themepark][:version] = "b7bf8d5519b7809370f9a92d7fceda74266775dd"

default[:postgresql][:versions] |= [node[:vectortile][:database][:cluster].split("/").first]
default[:postgresql][:monitor_database] = "tiles"
# As an absolute worst case, the server might have the serving, update, and a manual generation process going on.
# Each of these connects to two databases, then we add more connections so 20% are unused and we're
# not tripping alarms.
default[:postgresql][:settings][:defaults][:max_connections] = (node.cpu_cores * 8 + 20).to_s
