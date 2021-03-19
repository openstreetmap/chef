default[:prometheus][:addresses] = {}
default[:prometheus][:exporters] = {}
default[:prometheus][:snmp] = {}

if node[:recipes].include?("prometheus::server")
  default[:apt][:sources] |= ["grafana"]
end
