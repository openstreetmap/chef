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
  }
)

run_list(
  "role[gb]"
)
