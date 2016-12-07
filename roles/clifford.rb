name "clifford"
description "Master role applied to clifford"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "enp2s0f0.2801",
        :role => :internal,
        :family => :inet,
        :address => "10.0.0.17"
      },
      :external_ipv4 => {
        :interface => "enp2s0f0.2800",
        :role => :external,
        :family => :inet,
        :address => "193.60.236.11"
      }
    }
  }
)

run_list(
  "role[ucl-slough]",
  "role[hp-dl360-g6]",
  "role[forum]"
)
