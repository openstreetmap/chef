default[:networking][:firewall][:enabled] = true
default[:networking][:firewall][:sets] = []
default[:networking][:firewall][:helpers] = []
default[:networking][:firewall][:incoming] = []
default[:networking][:firewall][:outgoing] = []
default[:networking][:firewall][:http_rate_limit] = nil
default[:networking][:firewall][:http_connection_limit] = nil
default[:networking][:firewall][:allowlist] = []
default[:networking][:roles] = {}
default[:networking][:interfaces] = {}
default[:networking][:nameservers] = %w[1.1.1.1#cloudflare-dns.com 1.0.0.1#cloudflare-dns.com 2606:4700:4700::1111#cloudflare-dns.com 2606:4700:4700::1001#cloudflare-dns.com 8.8.8.8#dns.google 8.8.4.4#dns.google 2001:4860:4860::8888#dns.google 2001:4860:4860::8844#dns.google 9.9.9.9#dns.quad9.net 149.112.112.112#dns.quad9.net 2620:fe::fe#dns.quad9.net 2620:fe::9#dns.quad9.net]
default[:networking][:search] = []
default[:networking][:dnssec] = "allow-downgrade"

default[:networking][:dnsovertls] = if platform?("debian")
                                      "opportunistic"
                                    elsif node[:lsb][:release].to_f < 22.04
                                      "no"
                                    else
                                      "opportunistic"
                                    end

default[:networking][:hostname] = node.name
default[:networking][:wireguard][:enabled] = true
default[:networking][:wireguard][:keepalive] = 180
default[:networking][:wireguard][:peers] = []
