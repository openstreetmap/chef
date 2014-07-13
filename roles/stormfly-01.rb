name "stormfly-01"
description "Master role applied to stormfly-01"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet,
        :address => "140.211.167.104"
      }
    }
  }
)

run_list(
  "role[osuosl]"
)
