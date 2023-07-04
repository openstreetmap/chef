default[:db][:cluster] = "15/main"

default[:postgresql][:versions] |= ["15"]
default[:postgresql][:monitor_database] = "openstreetmap"
