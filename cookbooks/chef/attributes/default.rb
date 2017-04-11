# Add the opscode APT source for chef
default[:apt][:sources] = node[:apt][:sources] | ["opscode"]

# Set the default server version
default[:chef][:server][:version] = "12.13.0-1"

# Set the default client version
default[:chef][:client][:version] = "12.19.36"
