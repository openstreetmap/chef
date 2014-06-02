# Add the opscode APT source for chef
default[:apt][:sources] = node[:apt][:sources] | [ "opscode" ]

# Set the default server version
default[:chef][:server][:version] = "11.0.12-1"

# Set the default client version
default[:chef][:client][:version] = "11.12.4-1"

# A list of gems needed by chef recipes
default[:chef][:gems] = []
