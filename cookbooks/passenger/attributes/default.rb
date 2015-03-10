default[:passenger][:version] = 5
default[:passenger][:ruby_version] = "1.9.1"
default[:passenger][:max_pool_size] = 6
default[:passenger][:pool_idle_time] = 300

if node[:passenger][:version] == 4
  default[:apt][:sources] = node[:apt][:sources] |  ["brightbox-ruby-ng", "passenger4"]
else
  default[:apt][:sources] = node[:apt][:sources] |  ["brightbox-ruby-ng", "passenger"]
end
