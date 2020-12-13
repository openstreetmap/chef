default[:tile][:database][:cluster] = "12/main"
default[:tile][:database][:postgis] = "3"
default[:tile][:database][:node_file] = "/store/database/nodes"
default[:tile][:database][:multi_geometry] = true
default[:tile][:database][:hstore] = true
default[:tile][:database][:style_file] = nil
default[:tile][:database][:tag_transform_script] = nil

default[:tile][:replication][:url] = "https://planet.osm.org/replication/minute/"

default[:tile][:data] = {}
default[:tile][:styles] = {}

default[:postgresql][:versions] |= [node[:tile][:database][:cluster].split("/").first]

default[:accounts][:users][:tile][:status] = :role
