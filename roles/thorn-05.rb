name "thorn-05"
description "Master role applied to thorn-05"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "bond0",
        :role => :internal,
        :family => :inet,
        :address => "10.0.32.42",
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
