name "gandi"
description "Role applied to all servers at Gandi"

default_attributes(
  :hosted_by => "Gandi",
  :location => "Bissen, Luxembourg"
)

override_attributes(
  :networking => {
    :nameservers => ["217.70.186.194", "217.70.186.193", "2001:4b98:dc2:49::193"]
  },
  :ntp => {
    :servers => ["0.lu.pool.ntp.org", "1.lu.pool.ntp.org", "europe.pool.ntp.org"]
  }
)

run_list(
  "role[lu]"
)
