name "tabaluga"
description "Master role applied to tabaluga"

default_attributes(
  :dhcpd => {
    :first_address => "10.0.62.1",
    :last_address => "10.0.62.254"
  },
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "bond0",
        :role => :internal,
        :family => :inet,
        :address => "10.0.48.14",
        :bond => {
          :slaves => %w[eno1 eno2]
        }
      },
      :external_ipv4 => {
        :interface => "bond0.2",
        :role => :external,
        :family => :inet,
        :address => "130.117.76.14"
      },
      :external_ipv6 => {
        :interface => "bond0.2",
        :role => :external,
        :family => :inet6,
        :address => "2001:978:2:2C::172:E"
      }
    }
  }
)

run_list(
  "role[equinix]",
  "role[hp-g9]",
  "role[wiki]",
  "recipe[dhcpd]"
)
