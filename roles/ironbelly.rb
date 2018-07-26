name "ironbelly"
description "Master role applied to ironbelly"

default_attributes(
  :apt => {
    :sources => ["ubuntugis-unstable"]
  },
  :dhcpd => {
    :first_address => "10.0.63.1",
    :last_address => "10.0.63.254"
  },
  :elasticsearch => {
    :cluster => {
      :routing => {
        :allocation => {
          :disk => {
            :watermark => {
              :low => "95%",
              :high => "98%"
            }
          }
        }
      }
    },
    :path => {
      :data => "/store/elasticsearch"
    }
  },
  :munin => {
    :graphs => {
      :apcpdu_ams => {
        :title => "Current for Amsterdam",
        :vlabel => "Amps",
        :category => "Ups",
        :values => {
          :load => {
            :sum => ["apcpdu_pdu1.load", "apcpdu_pdu2.load"],
            :label => "Load"
          }
        }
      }
    }
  },
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "bond0",
        :role => :internal,
        :family => :inet,
        :address => "10.0.48.10",
        :bond => {
          :slaves => %w[eth0 eth1]
        }
      },
      :external_ipv4 => {
        :interface => "bond0.2",
        :role => :external,
        :family => :inet,
        :address => "130.117.76.10"
      },
      :external_ipv6 => {
        :interface => "bond0.2",
        :role => :external,
        :family => :inet6,
        :address => "2001:978:2:2C::172:A"
      }
    }
  },
  :openvpn => {
    :address => "10.0.16.2",
    :tunnels => {
      :ic2ucl => {
        :port => "1194",
        :mode => "server",
        :peer => {
          :host => "ridley.openstreetmap.org"
        }
      },
      :aws2ic => {
        :port => "1195",
        :mode => "server",
        :peer => {
          :host => "fafnir.openstreetmap.org"
        }
      },
      :ic2bm => {
        :port => "1196",
        :mode => "client",
        :peer => {
          :host => "grisu.openstreetmap.org",
          :port => "1194"
        }
      }
    }
  },
  :planet => {
    :replication => "disabled"
  },
  :rsyncd => {
    :modules => {
      :hosts => {
        :comment => "Host data",
        :path => "/home/hosts",
        :read_only => true,
        :write_only => false,
        :list => false,
        :uid => "tomh",
        :gid => "tomh",
        :transfer_logging => false,
        :hosts_allow => [
          "212.110.172.32",                      # shenron
          "2001:41c9:1:400::32",                 # shenron
          "212.159.112.221"                      # grant
        ]
      },
      :logs => {
        :comment => "Log files",
        :path => "/store/logs",
        :read_only => false,
        :write_only => true,
        :list => false,
        :uid => "www-data",
        :gid => "www-data",
        :transfer_logging => false,
        :hosts_allow => [
          "193.60.236.0/24",          # ucl external
          "10.0.48.0/20",             # equinix internal
          "130.117.76.0/27",          # equinix external
          "2001:978:2:2C::172:0/112", # equinix external
          "10.0.32.0/20",             # bytemark internal
          "89.16.162.16/28",          # bytemark external
          "2001:41c9:2:d6::/64",      # bytemark external
          "127.0.0.0/8",              # localhost
          "::1"                       # localhost
        ],
        :nodes_allow => "roles:tilecache"
      }
    }
  }
)

run_list(
  "role[equinix]",
  "role[gateway]",
  "role[web-storage]",
  "role[supybot]",
  "role[backup]",
  "role[stats]",
  "role[planet]",
  # "role[planetdump]",
  "role[logstash]",
  "recipe[rsyncd]",
  "recipe[dhcpd]",
  "recipe[openvpn]",
  "recipe[tilelog]"
)
