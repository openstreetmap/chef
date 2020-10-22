name "spike-04"
description "Master role applied to spike-04"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "bond0",
        :role => :internal,
        :family => :inet,
        :address => "10.0.32.21",
        :bond => {
          :slaves => %w[enp3s0f0 enp3s0f1]
        }
      },
      :external_ipv4 => {
        :interface => "bond0.214",
        :role => :external,
        :family => :inet,
        :address => "89.16.162.21"
      },
      :external_ipv6 => {
        :interface => "bond0.214",
        :role => :external,
        :family => :inet6,
        :address => "2001:41c9:2:d6::21"
      }
    }
  }
)

run_list(
  "role[bytemark]",
  "role[web-frontend]"
  # "role[web-gpximport]",
  # "role[web-statistics]",
  # "role[web-cleanup]"
)
