name "lockheed"
description "Master role applied to lockheed"

default_attributes(
  :networking => {
    :interfaces => {
      :internal => {
        :interface => "bond0",
        :role => :internal,
        :inet => {
          :address => "10.0.48.16"
        },
        :bond => {
          :mode => "802.3ad",
          :lacprate => "fast",
          :xmithashpolicy => "layer3+4",
          :slaves => %w[eno49 eno50]
        }
      },
      :external_he => {
        :interface => "bond0.3",
        :role => :external,
        :metric => 150,
        :source_route_table => 100,
        :inet => {
          :address => "184.104.179.144",
          :prefix => "27",
          :gateway => "184.104.179.129"
        },
        :inet6 => {
          :address => "2001:470:1:fa1::10",
          :prefix => 64,
          :gateway => "2001:470:1:fa1::1"
        }
      },
      :external => {
        :interface => "bond0.103",
        :role => :external,
        :source_route_table => 150,
        :inet => {
          :address => "82.199.86.112",
          :prefix => "27",
          :gateway => "82.199.86.97"
        },
        :inet6 => {
          :address => "2001:4d78:500:5e3::10",
          :prefix => 64,
          :gateway => "2001:4d78:500:5e3::1"
        }
      }
    }
  },
  :sysctl => {
    :sockets => {
      :comment => "Increase size of connection queue",
      :parameters => {
        "net.core.somaxconn" => 10000
      }
    },
    :network_conntrack_time_wait => {
      :comment => "Only track completed connections for 30 seconds",
      :parameters => {
        "net.netfilter.nf_conntrack_tcp_timeout_time_wait" => "30"
      }
    },
    :network_conntrack_max => {
      :comment => "Increase max number of connections tracked",
      :parameters => {
        "net.netfilter.nf_conntrack_max" => "524288"
      }
    },
    :no_tcp_slow_start => {
      :comment => "Disable TCP slow start",
      :parameters => {
        "net.ipv4.tcp_slow_start_after_idle" => "0"
      }
    },
    :tcp_use_bbr => {
      :comment => "Use TCP BBR Congestion Control",
      :parameters => {
        "net.core.default_qdisc" => "fq",
        "net.ipv4.tcp_congestion_control" => "bbr"
      }
    }
  },
  :nginx => {
    :cache => {
      :fastcgi => {
        :enable => true,
        :keys_zone => "fastcgi_cache_zone:2048M",
        :inactive => "180d",
        :max_size => "196608M"
      },
      :proxy => {
          :enable => true,
          :keys_zone => "proxy_cache_zone:2048M",
          :inactive => "180d",
          :max_size => "196608M"
      }
    }
  }
)

run_list(
  "role[equinix-ams]",
  "role[hp-g9]",
  "role[imagery]"
)
