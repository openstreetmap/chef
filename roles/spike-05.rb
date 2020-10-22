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
          :slaves => %w[enp3s0f0 enp3s0f1]
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
  }
)

run_list(
  "role[bytemark]",
  "role[web-frontend]"
)
