default[:vectortile][:database][:cluster] = "16/main"
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
default[:vectortile][:spirit][:version] = "b4168097384be34da31c41bc616114cceaec24dd"
default[:vectortile][:themepark][:version] = "15dc14b1a045efc763c210ab959d6643f9d54384"

default[:postgresql][:versions] |= [node[:vectortile][:database][:cluster].split("/").first]
default[:postgresql][:monitor_database] = "tiles"
# As an absolute worst case, the server might have the serving, update, and a manual generation process going on.
# Each of these connects to two databases, then we add more connections so 20% are unused and we're
# not tripping alarms.
default[:postgresql][:settings][:defaults][:max_connections] = (node.cpu_cores * 8 + 20).to_s
