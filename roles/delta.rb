name "delta"
description "Role applied to all servers at Delta Telecom"

default_attributes(
  :networking => {
    :nameservers => [ "94.20.20.20", "8.8.8.8", "8.8.4.4" ],
    :roles => {
      :external => {
        :zone => "dt"
      }
    }
  }
)

override_attributes(
  :ntp => {
    :servers => [ "0.az.pool.ntp.org", "1.az.pool.ntp.org", "europe.pool.ntp.org" ]
  }
)

run_list(
  "role[az]"
)
