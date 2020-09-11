name "tiamat-11"
description "Master role applied to tiamat-11"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "enp1s0.2801",
        :role => :internal,
        :family => :inet,
        :address => "10.0.0.45"
      },
      :external_ipv4 => {
        :interface => "enp1s0.2800",
        :role => :external,
        :family => :inet,
        :address => "193.60.236.45"
      }
    }
  }
)

run_list(
  "role[ucl]",
  "role[supermicro-x8dtt-h]",
  "role[prometheus]"
)
