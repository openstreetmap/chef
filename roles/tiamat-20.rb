name "tiamat-20"
description "Master role applied to tiamat-20"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "enp1s0.2801",
        :role => :internal,
        :family => :inet,
        :address => "10.0.0.48"
      },
      :external_ipv4 => {
        :interface => "enp1s0.2800",
        :role => :external,
        :family => :inet,
        :address => "193.60.236.48"
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
