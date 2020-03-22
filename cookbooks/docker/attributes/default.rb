# Add the docker APT source
default[:apt][:sources] = node[:apt][:sources] | ["docker"]
