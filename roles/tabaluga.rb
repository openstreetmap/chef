name "tabaluga"
description "Master role applied to tabaluga"

default_attributes(
  :dhcpd => {
    :first_address => "10.0.63.1",
    :last_address => "10.0.63.254"
  },
  :networking => {
    :interfaces => {
      :internal => {
        :inet => {
          :address => "10.0.48.14"
        },
        :bond => {
          :slaves => %w[eno1 eno2]
        }
      },
      :henet => {
        :inet => {
          :address => "184.104.179.142"
        },
        :inet6 => {
          :address => "2001:470:1:fa1::e"
        }
      },
      :equinix => {
        :inet => {
          :address => "82.199.86.110"
        },
        :inet6 => {
          :address => "2001:4d78:500:5e3::e"
        }
      }
    }
  },
  :prometheus => {
    :junos => {
      "switch1" => { :address => "184.104.179.129", :labels => { "site" => "amsterdam" } }
    },
    :snmp => {
      "pdu1" => { :address => "10.0.48.100", :modules => %w[apcups], :labels => { "site" => "amsterdam" } },
      "pdu2" => { :address => "10.0.48.101", :modules => %w[apcups], :labels => { "site" => "amsterdam" } }
    },
    :metrics => {
      :uplink_interface => {
        :help => "Site uplink interface name",
        :labels => { :site => "amsterdam", :name => "xe-[01]/2/0|ge-[01]/2/2" }
      }
    }
  }
)

run_list(
  "role[equinix-ams-public]",
  "role[hp-g9]",
  "role[blog-staging]",
  "role[taginfo]",
  "role[gateway]",
  "recipe[dhcpd]"
)
