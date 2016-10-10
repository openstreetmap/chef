
default[:tilecache][:tile_parent] = "parent.tile.openstreetmap.org"
default[:tilecache][:tile_siblings] = []

# Per IP bucket refill rate
default[:tilecache][:ip_bucket_refill] = 307200
# Per IP bucket size
default[:tilecache][:ip_bucket_size] = 15728640
# Per Class C refill rate
default[:tilecache][:net_bucket_refill] = 39321600
# Per Class C bucket size
default[:tilecache][:net_bucket_size] = 2013265920

default[:tilecache][:ssl][:certificate] = "tile.openstreetmap"
