name "ovh-ca"
description "Role applied to all servers at OVH CA"

override_attributes(
  :ntp => {
    :servers => ["0.ca.pool.ntp.org", "1.ca.pool.ntp.org", "north-america.pool.ntp.org"]
  }
)

run_list(
  "role[ca]",
  "role[ovh]"
)
