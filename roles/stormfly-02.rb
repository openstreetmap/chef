name "stormfly-02"
description "Master role applied to stormfly-02"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "eth0",
        :role => :internal,
        :family => :inet,
        :address => "10.0.0.108"
      }
    }
  }
)

run_list(
  "role[osuosl]"
)
