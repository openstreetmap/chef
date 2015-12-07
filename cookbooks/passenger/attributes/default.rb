default[:passenger][:ruby_version] = "2.1"
default[:passenger][:max_pool_size] = 6
default[:passenger][:pool_idle_time] = 300

default[:apt][:sources] = node[:apt][:sources] | ["brightbox-ruby-ng", "passenger"]
