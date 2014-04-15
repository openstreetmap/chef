
default[:tilecache][:tile_parent] = "parent.tile.openstreetmap.org"
default[:tilecache][:tile_siblings] = []

#Per IP bucket refill rate
default[:tilecache][:ip_bucket_refill] = "8192"
#Per IP bucket size
default[:tilecache][:ip_bucket_size] = "16777216"
#Per Class C refill rate
default[:tilecache][:net_bucket_refill] = "32768"
#Per Class C bucket size
default[:tilecache][:net_bucket_size] = "33554432"

default[:tilecache][:ssl][:certificate] = "tile.openstreetmap"

