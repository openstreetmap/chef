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

default[:vectortile][:tilekiln][:version] = "0.7.1"
default[:vectortile][:spirit][:version] = "7fc3c62771d371f00a62249174d4d695d8324443"
default[:vectortile][:themepark][:version] = "beb454cc56e88533fb398ab293489c4e91f4d42b"

default[:postgresql][:versions] |= [node[:vectortile][:database][:cluster].split("/").first]
default[:postgresql][:monitor_database] = "tiles"
# As an absolute worst case, the server might have the serving, update, and a manual generation process going on.
default[:postgresql][:settings][:defaults][:max_connections] = (node.cpu_cores * 6 + 20).to_s
default[:accounts][:users][:tileupdate][:status] = :role
default[:accounts][:users][:tilekiln][:status] = :role
