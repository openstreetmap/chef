name "tiamat-00"
description "Master role applied to tiamat-00"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "enp1s0.2801",
        :role => :internal,
        :family => :inet,
        :address => "10.0.0.40"
      },
      :external_ipv4 => {
        :interface => "enp1s0.2800",
        :role => :external,
        :family => :inet,
        :address => "193.60.236.40"
      }
    }
  }
)

run_list(
  "role[ucl]",
  "role[supermicro-x8dtt-h]",
  "role[crm]"
)
