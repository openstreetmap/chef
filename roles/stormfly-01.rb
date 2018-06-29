name "stormfly-01"
description "Master role applied to stormfly-01"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "em1",
        :role => :external,
        :family => :inet,
        :address => "140.211.167.104"
      },
      :external_ipv6 => {
        :interface => "em1",
        :role => :external,
        :family => :inet6,
        :address => "2605:bc80:3010:700::8cde:a768"
      }
    }
  }
)

run_list(
  "role[osuosl]",
  "role[hp-dl360-g6]",
  "role[wiki]"
)
