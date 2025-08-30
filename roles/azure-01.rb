name "azure-01"
description "Master role applied to azure-01"

default_attributes(
  :networking => {
    :interfaces => {
      :external => {
        :interface => "bond0",
        :role => :external,
        :inet => {
          :address => "103.147.22.156",
          :prefix => "24",
          :gateway => "103.147.22.254"
        },
        :bond => {
          :mode => "802.3ad",
          :lacprate => "slow",
          :xmithashpolicy => "layer3+4",
          :slaves => %w[ens1f0np0 ens1f1np1]
        }
      }
    }
  }
)

run_list(
  "role[twds]"
)
