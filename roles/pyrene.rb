name "pyrene"
description "Master role applied to pyrene"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eno1",
        :role => :external,
        :family => :inet,
        :address => "140.211.15.29",
        :prefix => "24",
        :gateway => "140.211.15.1"
      }
    }
  }
)

run_list(
  "role[osuosl]"
)
