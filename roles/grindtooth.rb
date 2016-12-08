name "grindtooth"
description "Master role applied to grindtooth"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "em1.2801",
        :role => :internal,
        :family => :inet,
        :address => "10.0.0.19"
      },
      :external_ipv4 => {
        :interface => "em1.2800",
        :role => :external,
        :family => :inet,
        :address => "193.60.236.15"
      }
    }
  }
)

run_list(
  "role[ucl]",
  "role[hp-dl360-g6]",
  "role[taginfo]"
)
