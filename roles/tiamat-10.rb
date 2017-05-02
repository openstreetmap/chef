name "tiamat-10"
description "Master role applied to tiamat-10"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "enp1s0.2801",
        :role => :internal,
        :family => :inet,
        :address => "10.0.0.44"
      },
      :external_ipv4 => {
        :interface => "enp1s0.2800",
        :role => :external,
        :family => :inet,
        :address => "193.60.236.44"
      }
    }
  },
  :hardware => {
    :watchdog => "w83627hf_wdt"
  }
)

run_list(
  "role[ucl]"
)
