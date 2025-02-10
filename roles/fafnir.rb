name "fafnir"
description "Master role applied to fafnir"

default_attributes(
  :dhcpd => {
    :first_address => "10.0.79.1",
    :last_address => "10.0.79.254"
  },
  :exim => {
    :external_interface => "<;${if <{${randint:100}}{50} {184.104.226.98;2001:470:1:b3b::2}{87.252.214.98;2001:4d78:fe03:1c::2}}",
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
      :external_he => {
        :interface => "bond0.101",
        :role => :external,
        :source_route_table => 100,
        :inet => {
          :address => "184.104.226.98",
          :prefix => "27",
          :gateway => "184.104.226.97"
        },
        :inet6 => {
          :address => "2001:470:1:b3b::2",
          :prefix => 64,
          :gateway => "2001:470:1:b3b::1"
        }
      },
      :external => {
        :interface => "bond0.203",
        :role => :external,
        :metric => 150,
        :source_route_table => 150,
        :inet => {
          :address => "87.252.214.98",
          :prefix => "27",
          :gateway => "87.252.214.97"
        },
        :inet6 => {
          :address => "2001:4d78:fe03:1c::2",
          :prefix => 64,
          :gateway => "2001:4d78:fe03:1c::1"
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
