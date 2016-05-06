name "spike-05"
description "Master role applied to spike-05"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "bond0",
        :role => :internal,
        :family => :inet,
        :address => "10.0.32.22",
        :bond => {
          :slaves => %w(eth0 eth1)
        }
      },
      :external_ipv4 => {
        :interface => "bond0.214",
        :role => :external,
        :family => :inet,
        :address => "89.16.162.22"
      },
      :external_ipv6 => {
        :interface => "bond0.214",
        :role => :external,
        :family => :inet6,
        :address => "2001:41c9:2:d6::22"
      }
    }
  },
  :sysctl => {
    :ipv6_autoconf => {
      :comment => "Disable IPv6 auto-configuration on internal interface",
      :parameters => {
        "net.ipv6.conf.bond0.autoconf" => "0",
        "net.ipv6.conf.bond0.accept_ra" => "0"
      }
    }
  }
)

run_list(
  "role[bm]",
  "role[web-frontend]"
)
