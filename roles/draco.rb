name "draco"
description "Master role applied to draco"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "enp3s0f0.2801",
        :role => :internal,
        :family => :inet,
        :address => "10.0.0.11"
      },
      :external_ipv4 => {
        :interface => "enp3s0f0.2800",
        :role => :external,
        :family => :inet,
        :address => "193.60.236.12"
      }
    }
  }
)

run_list(
  "role[ucl]"
)
