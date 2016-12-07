name "eustace"
description "Master role applied to eustace"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "eth1",
        :role => :internal,
        :family => :inet,
        :address => "10.0.0.9"
      },
      :external_ipv4 => {
        :interface => "eth1.2800",
        :role => :external,
        :family => :inet,
        :address => "193.60.236.14"
      }
    }
  }
)

run_list(
  "role[ucl-slough]",
  "role[hp-dl360-g6]",
  "role[piwik]"
)
