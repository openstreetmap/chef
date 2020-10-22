name "thorn-04"
description "Master role applied to thorn-04"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "bond0",
        :role => :internal,
        :family => :inet,
        :address => "10.0.32.41",
        :bond => {
          :slaves => %w[enp3s0f0 enp3s0f1]
        }
      }
    }
  }
)

run_list(
  "role[bytemark]"
)
