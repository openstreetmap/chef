name "firefishynet"
description "Role applied to all servers at Firefishy"

default_attributes(
  :networking => {
    :nameservers => ["8.8.8.8", "8.8.4.4"],
    :roles => {
      :internal => {
        :inet => {
          :prefix => "24",
          :gateway => "10.89.121.1",
        },
      },
      :external => {
        :zone => "ff",
      },
    },
  }
)

run_list(
  "role[gb]"
)
