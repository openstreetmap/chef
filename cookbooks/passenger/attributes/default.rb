default[:passenger][:ruby_version] = node[:lsb][:release].to_f >= 18.04 ? "2.5" : "2.3"
default[:passenger][:max_pool_size] = 6
default[:passenger][:pool_idle_time] = 300
default[:passenger][:instance_registry_dir] = "/run/passenger"

default[:apt][:sources] = node[:apt][:sources] | ["passenger"]
