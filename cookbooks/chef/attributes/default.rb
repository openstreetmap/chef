# Add the opscode APT source for chef
default[:apt][:sources] = node[:apt][:sources] | ["opscode"]

# Set the default server version
default[:chef][:server][:version] = "12.0.8-1"

# Set the default client version
default[:chef][:client][:version] = "12.10.24-1"
