name "prgmr"
description "Role applied to all servers at prgmr.com"

default_attributes(
  :networking => {
    :nameservers => ["8.8.4.4", "65.19.174.2", "65.19.175.2"],
    :roles => {
      :external => {
        :zone => "pr"
      }
    }
  }
)

override_attributes(
  :ntp => {
    :servers => ["0.us.pool.ntp.org", "1.us.pool.ntp.org", "2.us.pool.ntp.org"]
  }
)

run_list(
  "role[us]"
)
