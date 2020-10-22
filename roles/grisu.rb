name "grisu"
description "Master role applied to grisu"

default_attributes(
  :bind => {
    :clients => "bytemark"
  },
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "bond0",
        :role => :internal,
        :family => :inet,
        :address => "10.0.32.20",
        :bond => {
          :slaves => %w[enp2s0f0 enp2s0f1]
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
  "role[planet]"
  # "role[planetdump]"
)
