name "snap-01"
description "Master role applied to snap-01"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "bond0",
        :role => :internal,
        :family => :inet,
        :address => "10.0.48.49",
        :bond => {
          :slaves => %w[eno1 eno2 eno3 eno4]
        }
      }
    }
  }
)

run_list(
  "role[equinix]"
)
