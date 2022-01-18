default[:prometheus][:addresses] = {}
default[:prometheus][:exporters] = {}
default[:prometheus][:snmp] = {}
default[:prometheus][:metrics] = {}
default[:prometheus][:files] = []
default[:prometheus][:promscale] = false

if node[:recipes].include?("prometheus::server")
  default[:apt][:sources] |= %w[grafana timescaledb]
end
