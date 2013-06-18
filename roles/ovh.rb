name "ovh"
description "Role applied to all servers at OVH"

default_attributes(
  :networking => {
    :nameservers => [ "8.8.4.4", "213.186.33.99", "8.8.8.8" ],
    :roles => {
      :external => {
        :zone => "ov"
      }
    }
  }
)
