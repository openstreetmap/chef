name "fafnir"
description "Master role applied to fafnir"

default_attributes(
  :dhcpd => {
    :first_address => "10.0.79.1",
    :last_address => "10.0.79.254"
  },
  :exim => {
    :external_interface => "<;${if <{${randint:100}}{75} {184.104.226.98;2001:470:1:b3b::2}{87.252.214.98;2001:4d78:fe03:1c::2}}",
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
        :inet => {
          :address => "10.0.64.2"
        },
        :bond => {
          :slaves => %w[eno1 eno2 eno3 eno4 eno49 eno50]
        }
      },
      :henet => {
        :inet => {
          :address => "184.104.226.98"
        },
        :inet6 => {
          :address => "2001:470:1:b3b::2"
        }
      },
      :equinix => {
        :inet => {
          :address => "87.252.214.98"
        },
        :inet6 => {
          :address => "2001:4d78:fe03:1c::2"
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
  "role[equinix-dub-public]",
  "role[hp-g9]",
  "role[gateway]",
  "role[mail]",
  "recipe[dhcpd]"
)
