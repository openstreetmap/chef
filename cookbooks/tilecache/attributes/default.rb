default[:tilecache][:tile_parent] = "render.openstreetmap.org"

# Per IP bucket refill rate
default[:tilecache][:ip_bucket_refill] = 4096
# Per IP bucket size
default[:tilecache][:ip_bucket_size] = 67108864
# Per Class C refill rate
default[:tilecache][:net_bucket_refill] = 8192
# Per Class C bucket size
default[:tilecache][:net_bucket_size] = 134217728

# Enable nginx cache
default[:nginx][:cache][:proxy][:enable] = true
