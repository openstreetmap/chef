default[:tile][:database][:cluster] = "10/main"
default[:tile][:database][:postgis] = "2.4"
default[:tile][:database][:node_file] = "/store/database/nodes"
default[:tile][:database][:multi_geometry] = true
default[:tile][:database][:hstore] = true
default[:tile][:database][:style_file] = nil
default[:tile][:database][:tag_transform_script] = nil

default[:tile][:data] = {}
default[:tile][:styles] = {}

default[:postgresql][:versions] |= ["10"]

default[:accounts][:users][:tile][:status] = :role
