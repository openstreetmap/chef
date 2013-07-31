name "bluehost"
description "Role applied to all servers at Bluehost"

default_attributes(
  :networking => {
    :nameservers => [ "8.8.8.8", "8.8.4.4" ],
    :roles => {
      :external => {
        :zone => "bh"
      }
    }
  }
)

override_attributes(
  :ntp => {
    :servers => [ "0.us.pool.ntp.org", "1.us.pool.ntp.org", "north-america.pool.ntp.org" ]
  }
)

run_list(
  "role[us]"
)
