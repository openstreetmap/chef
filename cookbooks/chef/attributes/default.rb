# Add the opscode APT source for chef
default[:apt][:sources] = node[:apt][:sources] | [ "opscode" ]

# Set the default client version
default[:chef][:client][:version] = "11.10.2-1"

# A list of gems needed by chef recipes
default[:chef][:gems] = []
