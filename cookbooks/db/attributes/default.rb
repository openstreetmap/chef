default[:db][:cluster] = "15/main"

default[:postgresql][:versions] |= %w[15 17]
default[:postgresql][:clusters]["15/main"][:pgbackrest_stanza] = "main"
default[:postgresql][:monitor_database] = "openstreetmap"
