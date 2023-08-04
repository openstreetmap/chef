name "fafnir"
description "Master role applied to fafnir"

default_attributes(
  :dhcpd => {
    :first_address => "10.0.79.1",
    :last_address => "10.0.79.254"
  },
  :exim => {
    :routes => {
      :openstreetmap => {
        :comment => "openstreetmap.org",
        :domains => ["openstreetmap.org"],
        :host => ["shenron.openstreetmap.org"]
      }
    }
  },
  :networking => {
    :interfaces => {
      :internal => {
        :interface => "bond0",
        :role => :internal,
        :inet => {
          :address => "10.0.64.2"
        },
        :bond => {
          :mode => "802.3ad",
          :lacprate => "fast",
          :xmithashpolicy => "layer3+4",
          :slaves => %w[eno1 eno2 eno3 eno4 eno49 eno50]
        }
      },
      :external => {
        :interface => "bond0.101",
        :role => :external,
        :inet => {
          :address => "184.104.226.98"
        },
        :inet6 => {
          :address => "2001:470:1:b3b::2"
        }
      }
    }
  },
  :prometheus => {
    :junos => {
      "switch1" => { :address => "184.104.226.97", :labels => { "site" => "dublin" } }
    },
    :snmp => {
      "pdu1" => { :address => "10.0.64.100", :modules => %w[apcups], :labels => { "site" => "dublin" } },
      "pdu2" => { :address => "10.0.64.101", :modules => %w[apcups], :labels => { "site" => "dublin" } }
    },
    :metrics => {
      :uplink_interface => {
        :help => "Site uplink interface name",
        :labels => { :site => "dublin", :name => "xe-[01]/2/[01]|ge-[01]/2/2" }
      }
    }
  }
)

run_list(
  "role[equinix-dub]",
  "role[hp-g9]",
  "role[gateway]",
  "role[mail]",
  "recipe[dhcpd]"
)
