name "tiamat-21"
description "Master role applied to tiamat-21"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "enp1s0.2801",
        :role => :internal,
        :family => :inet,
        :address => "10.0.0.49",
      },
      :external_ipv4 => {
        :interface => "enp1s0.2800",
        :role => :external,
        :family => :inet,
        :address => "193.60.236.49",
      },
    },
  }
)

run_list(
  "role[ucl]",
  "role[supermicro-x8dtt-h]"
)
