default[:timescaledb][:database_version] = "13"
default[:timescaledb][:max_background_workers] = 8

default[:apt][:sources] |= ["timescaledb"]
