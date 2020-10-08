name "firefishynet"
description "Role applied to all servers at Firefishy"

default_attributes(
  :networking => {
    :roles => {
      :internal => {
        :inet => {
          :prefix => "24",
          :gateway => "10.89.121.1"
        }
      }
    }
  }
)

run_list(
  "role[gb]"
)
