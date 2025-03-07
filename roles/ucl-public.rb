name "ucl-public"
description "Role applied to all public servers at UCL"

default_attributes(
  :networking => {
    :interfaces => {
      :external => {
        :role => :external,
        :metric => 100,
        :zone => "ucl",
        :inet => {
          :prefix => "24",
          :gateway => "193.60.236.254"
        }
      }
    }
  }
)

run_list(
  "role[ucl]"
)
