name "tiamat-22"
description "Master role applied to tiamat-22"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "enp1s0.2801",
        :role => :internal,
        :family => :inet,
        :address => "10.0.0.50",
      },
      :external_ipv4 => {
        :interface => "enp1s0.2800",
        :role => :external,
        :family => :inet,
        :address => "193.60.236.50",
      },
    },
  }
)

run_list(
  "role[ucl]",
  "role[supermicro-x8dtt-h]"
)
