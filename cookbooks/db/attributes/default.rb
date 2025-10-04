default[:db][:cluster] = "15/main"

default[:postgresql][:versions] |= %w[15 17]
default[:postgresql][:monitor_database] = "openstreetmap"
