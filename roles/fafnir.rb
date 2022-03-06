name "fafnir"
description "Master role applied to fafnir"

default_attributes(
  :bind => {
    :clients => "equinix-dub"
  },
  :dhcpd => {
    :first_address => "10.0.79.1",
    :last_address => "10.0.79.254"
  },
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "bond0",
        :role => :internal,
        :family => :inet,
        :address => "10.0.64.2",
        :bond => {
          :mode => "802.3ad",
          :lacprate => "fast",
          :xmithashpolicy => "layer3+4",
          :slaves => %w[eno1 eno2 eno3 eno4 eno49 eno50]
        }
      },
      :external_ipv4 => {
        :interface => "bond0.101",
        :role => :external,
        :family => :inet,
        :address => "184.104.226.98"
      },
      :external_ipv6 => {
        :interface => "bond0.101",
        :role => :external,
        :family => :inet6,
        :address => "2001:470:1:b3b::2"
      }
    }
  },
  :prometheus => {
    :snmp => {
      "pdu1" => { :address => "10.0.64.100", :module => "apcups", :labels => { "site" => "dublin" } },
      "pdu2" => { :address => "10.0.64.101", :module => "apcups", :labels => { "site" => "dublin" } },
      "switch1" => { :address => "184.104.226.97", :module => "if_mib", :labels => { "site" => "dublin" } }
    },
    :metrics => {
      :uplink_interface => {
        :help => "Site uplink interface name",
        :labels => { :site => "dublin", :name => "ae50" }
      }
    }
  }
)

run_list(
  "role[equinix-dub]",
  "role[hp-g9]",
  "role[gateway]",
  "recipe[dhcpd]"
)
