name "norbert"
description "Master role applied to norbert"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "bond0",
        :role => :internal,
        :family => :inet,
        :address => "10.0.48.17",
        :bond => {
          :slaves => %w[enp25s0f0 enp25s0f1]
        }
      },
      :external_ipv4 => {
        :interface => "bond0.2",
        :role => :external,
        :family => :inet,
        :address => "130.117.76.17"
      },
      :external_ipv6 => {
        :interface => "bond0.2",
        :role => :external,
        :family => :inet6,
        :address => "2001:978:2:2C::172:11"
      }

    }
  }
)

run_list(
  "role[equinix-ams]",
  "role[planet]"
)
