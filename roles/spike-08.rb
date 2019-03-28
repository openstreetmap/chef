name "spike-08"
description "Master role applied to spike-08"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "bond0",
        :role => :internal,
        :family => :inet,
        :address => "10.0.48.13",
        :bond => {
          :slaves => %w[eno1 eno2]
        }
      },
      :external_ipv4 => {
        :interface => "bond0.2",
        :role => :external,
        :family => :inet,
        :address => "130.117.76.13"
      },
      :external_ipv6 => {
        :interface => "bond0.2",
        :role => :external,
        :family => :inet6,
        :address => "2001:978:2:2C::172:D"
      }
    }
  }
)

run_list(
  "role[equinix]",
  "role[hp-g9]",
  "role[web-frontend]"
)
