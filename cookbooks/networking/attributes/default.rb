default[:networking][:firewall][:enabled] = true
default[:networking][:firewall][:sets] = []
default[:networking][:firewall][:helpers] = []
default[:networking][:firewall][:incoming] = []
default[:networking][:firewall][:outgoing] = []
default[:networking][:firewall][:http_rate_limit] = nil
default[:networking][:firewall][:http_connection_limit] = nil
default[:networking][:firewall][:allowlist] = []
default[:networking][:interfaces] = {}
default[:networking][:nameservers] = %w[8.8.8.8 8.8.4.4 2001:4860:4860::8888 2001:4860:4860::8844]
default[:networking][:search] = []
default[:networking][:dnssec] = "false"
default[:networking][:hostname] = node.name
default[:networking][:wireguard][:enabled] = true
default[:networking][:wireguard][:keepalive] = 180
default[:networking][:wireguard][:peers] = []
