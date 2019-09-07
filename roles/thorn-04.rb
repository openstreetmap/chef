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
          :slaves => %w(em1 em2),
        },
      },
    },
  }
)

run_list(
  "role[bytemark]",
  "role[web-backend]"
)
