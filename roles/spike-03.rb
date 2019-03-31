name "spike-03"
description "Master role applied to spike-03"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "bond0",
        :role => :internal,
        :family => :inet,
        :address => "10.0.48.8",
        :bond => {
          :slaves => %w[eth0 eth1]
        }
      },
      :external_ipv4 => {
        :interface => "bond0.2",
        :role => :external,
        :family => :inet,
        :address => "130.117.76.8"
      },
      :external_ipv6 => {
        :interface => "bond0.2",
        :role => :external,
        :family => :inet6,
        :address => "2001:978:2:2C::172:8"
      }
    }
  },
  :sysctl => {
    :ipv6_autoconf => {
      :comment => "Disable IPv6 auto-configuration on internal interface",
      :parameters => {
        "net.ipv6.conf.eth0.autoconf" => "0",
        "net.ipv6.conf.eth0.accept_ra" => "0"
      }
    }
  }
)

run_list(
  "role[equinix]",
  "role[hp-dl360-g6]"
)
