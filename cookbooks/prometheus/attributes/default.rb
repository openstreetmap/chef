default[:prometheus][:exporters] = {}

if node[:recipes].include?("prometheus::server")
  default[:apt][:sources] |= ["grafana"]
end
