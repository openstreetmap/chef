name "blix-no"
description "Role applied to all servers at Blix NO"

override_attributes(
  :ntp => {
    :servers => ["0.no.pool.ntp.org", "1.no.pool.ntp.org", "europe.pool.ntp.org"]
  }
)

run_list(
  "role[no]",
  "role[blix]"
)
