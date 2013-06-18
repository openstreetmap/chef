name "blix-nl"
description "Role applied to all servers at Blix NL"

override_attributes(
  :ntp => {
    :servers => [ "0.nl.pool.ntp.org", "1.nl.pool.ntp.org", "europe.pool.ntp.org" ]
  }
)

run_list(
  "role[nl]",
  "role[blix]"
)
