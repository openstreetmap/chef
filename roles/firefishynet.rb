name "firefishynet"
description "Role applied to all servers at Firefishy"

default_attributes(
  :networking => {
    :nameservers => [ "8.8.8.8", "8.8.4.4" ],
    :roles => {
      :external => {
        :zone => "ff"
      }
    }
  }
)

run_list(
  "role[gb]"
)
