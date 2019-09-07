default[:squid][:version] = 2
default[:squid][:cache_mem] = "256 MB"
default[:squid][:cache_dir] = "ufs /var/spool/squid 256 16 256"
default[:squid][:access_log] = "/var/log/squid/access.log openstreetmap"

default[:apt][:sources] = node["apt"]["sources"] | ["squid#{node['squid']['version']}"]
