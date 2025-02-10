default[:vectortile][:database][:cluster] = "16/main"
default[:vectortile][:database][:postgis] = "3"
default[:vectortile][:database][:nodes_store] = :flat
default[:vectortile][:serve][:threads] = node.cpu_cores
default[:vectortile][:serve][:mode] = :live
default[:vectortile][:replication][:url] = "https://osm-planet-eu-central-1.s3.dualstack.eu-central-1.amazonaws.com/planet/replication/minute"
default[:vectortile][:replication][:status] = :enabled
default[:vectortile][:replication][:tileupdate] = :enabled
default[:vectortile][:replication][:threads] = node.cpu_cores

default[:vectortile][:tilekiln][:version] = "0.6.5"

default[:postgresql][:versions] |= [node[:vectortile][:database][:cluster].split("/").first]
default[:postgresql][:monitor_database] = "tiles"
# As an absolute worst case, the server might have the serving, update, and a manual generation process going on.
default[:postgresql][:settings][:defaults][:max_connections] = (node.cpu_cores * 6 + 20).to_s
default[:accounts][:users][:tileupdate][:status] = :role
default[:accounts][:users][:tilekiln][:status] = :role
