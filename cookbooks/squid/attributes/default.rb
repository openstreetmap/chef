default[:squid][:version] = 4
default[:squid][:cache_mem] = "256 MB"
default[:squid][:cache_dir] = "ufs /var/spool/squid 256 16 256"
default[:squid][:access_log] = "/var/log/squid/access.log openstreetmap"
default[:squid][:private_devices] = true

default[:apt][:sources] = node[:apt][:sources] | ["squid#{node[:squid][:version]}"]
