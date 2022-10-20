name "thorn-03"
description "Master role applied to thorn-03"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "bond0",
        :role => :internal,
        :family => :inet,
        :address => "10.0.48.53",
        :bond => {
          :mode => "802.3ad",
          :lacprate => "fast",
          :xmithashpolicy => "layer3+4",
          :slaves => %w[eth0 eth1]
        }
      }
    }
  }
)

run_list(
  "role[equinix-ams]"
)
