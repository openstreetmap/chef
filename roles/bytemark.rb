name "bytemark"
description "Role applied to all servers at Bytemark"

default_attributes(
  :networking => {
    :nameservers => [ "[2001:41c8:2::1]", "[2001:41c8:2::2]", "80.68.80.24", "80.68.80.25" ],
    :roles => {
      :external => {
        :zone => "bm"
      }
    }
  }
)

override_attributes(
  :ntp => {
    :servers => [ "0.uk.pool.ntp.org", "1.uk.pool.ntp.org", "europe.pool.ntp.org" ]
  }
)

run_list(
  "role[gb]"
)
