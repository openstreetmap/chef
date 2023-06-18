name "ironbelly"
description "Master role applied to ironbelly"

default_attributes(
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
              :high => "98%",
              :flood_stage => "99%"
            }
          }
        }
      }
    },
    :path => {
      :data => "/store/elasticsearch"
    }
  },
  :networking => {
    :interfaces => {
      :internal => {
        :interface => "bond0",
        :role => :internal,
        :inet => {
          :address => "10.0.48.10"
        },
        :bond => {
          :mode => "802.3ad",
          :lacprate => "fast",
          :xmithashpolicy => "layer3+4",
          :slaves => %w[eth0 eth1]
        }
      },
      :external => {
        :interface => "bond0.3",
        :role => :external,
        :inet => {
          :address => "184.104.179.138"
        },
        :inet6 => {
          :address => "2001:470:1:fa1::a"
        }
      }
    }
  },
  :prometheus => {
    :snmp => {
      "pdu1" => { :address => "10.0.48.100", :modules => %w[apcups], :labels => { "site" => "amsterdam" } },
      "pdu2" => { :address => "10.0.48.101", :modules => %w[apcups], :labels => { "site" => "amsterdam" } },
      "switch1" => { :address => "184.104.179.129", :modules => %w[if_mib juniper_ex4300], :labels => { "site" => "amsterdam" } }
    },
    :metrics => {
      :uplink_interface => {
        :help => "Site uplink interface name",
        :labels => { :site => "amsterdam", :name => "ge-[01]/2/[02]" }
      }
    }
  },
  :rsyncd => {
    :modules => {
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
          "10.0.48.0/20",             # amsterdam internal
          "184.104.179.128/27",       # amsterdam external
          "2001:470:1:fa1::/64",      # amsterdam external
          "10.0.64.0/20",             # dublin internal
          "184.104.226.96/27",        # dublin external
          "2001:470:1:b3b::/64",      # dublin external
          "10.0.32.0/20",             # bytemark internal
          "89.16.162.16/28",          # bytemark external
          "2001:41c9:2:d6::/64",      # bytemark external
          "127.0.0.0/8",              # localhost
          "::1"                       # localhost
        ]
      }
    }
  }
)

run_list(
  "role[equinix-ams]",
  "role[gateway]",
  "recipe[rsyncd]",
  "recipe[dhcpd]"
)
