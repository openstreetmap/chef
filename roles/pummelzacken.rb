name "pummelzacken"
description "Master role applied to pummelzacken"

default_attributes(
  :networking => {
    :interfaces => {
      :bond => {
        :interface => "bond0",
        :bond => {
          :slaves => %w[eno1 enp5s0f0]
        }
      },
      :internal_ipv4 => {
        :interface => "bond0.2801",
        :role => :internal,
        :family => :inet,
        :address => "10.0.0.20"
      },
      :external_ipv4 => {
        :interface => "bond0.2800",
        :role => :external,
        :family => :inet,
        :address => "193.60.236.18"
      }
    }
  }
)

run_list(
  "role[ucl]"
)
