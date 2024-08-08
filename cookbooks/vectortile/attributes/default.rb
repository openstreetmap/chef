default[:vectortile][:database][:cluster] = "16/main"
default[:vectortile][:database][:postgis] = "3"
default[:vectortile][:serve][:threads] = 2 # node.cpu_cores

default[:postgresql][:versions] |= [node[:vectortile][:database][:cluster].split("/").first]
default[:postgresql][:monitor_database] = "tiles"

default[:accounts][:users][:tileupdate][:status] = :role
default[:accounts][:users][:tilekiln][:status] = :role
