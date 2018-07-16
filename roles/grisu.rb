name "grisu"
description "Master role applied to grisu"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "bond0",
        :role => :internal,
        :family => :inet,
        :address => "10.0.32.20",
        :bond => {
          :slaves => %w[em1 em2]
        }
      },
      :external_ipv4 => {
        :interface => "bond0.214",
        :role => :external,
        :family => :inet,
        :address => "89.16.162.20"
      },
      :external_ipv6 => {
        :interface => "bond0.214",
        :role => :external,
        :family => :inet6,
        :address => "2001:41c9:2:d6::20"
      }
    }
  },
  :openvpn => {
    :address => "10.0.16.5",
    :tunnels => {
      :ic2bm => {
        :port => "1194",
        :mode => "server",
        :peer => {
          :host => "ironbelly.openstreetmap.org"
        }
      },
      :aws2bm => {
        :port => "1195",
        :mode => "server",
        :peer => {
          :host => "fafnir.openstreetmap.org"
        }
      },
      :ucl2bm => {
        :port => "1196",
        :mode => "server",
        :peer => {
          :host => "ridley.openstreetmap.org"
        }
      }
    }
  },
  :planet => {
    :replication => "disabled"
  }
)

run_list(
  "role[bytemark]",
  "role[hp-dl180-g6]",
  "role[gateway]",
  "role[web-storage]",
  "role[backup]",
  "role[planet]",
  "recipe[openvpn]"
)
