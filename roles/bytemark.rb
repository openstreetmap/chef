name "bytemark"
description "Role applied to all servers at Bytemark"

default_attributes(
  :hosted_by => "Bytemark",
  :location => "York, England"
)

override_attributes(
  :networking => {
    :nameservers => ["8.8.8.8", "8.8.4.4"],
    :search => ["bm.openstreetmap.org", "openstreetmap.org"]
  },
  :ntp => {
    :servers => ["0.uk.pool.ntp.org", "1.uk.pool.ntp.org", "europe.pool.ntp.org"]
  }
)

run_list(
  "role[gb]"
)
