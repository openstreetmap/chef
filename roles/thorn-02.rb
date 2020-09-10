name "thorn-02"
description "Master role applied to thorn-02"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "bond0",
        :role => :internal,
        :family => :inet,
        :address => "10.0.48.52",
        :bond => {
          :slaves => %w[eth0 eth1]
        }
      }
    }
  }
)

run_list(
  "role[equinix]"
)
