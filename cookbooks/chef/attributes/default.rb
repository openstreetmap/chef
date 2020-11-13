# Add the opscode APT source for chef
default[:apt][:sources] = node[:apt][:sources] | ["opscode"]

# Set the default server version
default[:chef][:server][:version] = "12.17.33"

# Set the default client version
default[:chef][:client][:version] = "16.6.14"
