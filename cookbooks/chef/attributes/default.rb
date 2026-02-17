# Set the default server version
default[:chef][:server][:version] = "15.9.38"

# Set the default client version
default[:chef][:client][:version] = "18.8.54"

# Default to using the chef client
default[:chef][:client][:cinc] = false
