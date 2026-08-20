name "inxza"
description "Role applied to all servers at INX-ZA"

default_attributes(
  :hosted_by => "INX-ZA",
  :location => "Cape Town, South Africa"
)

override_attributes(
  :networking => {
    :nameservers => ["196.10.52.52", "196.10.54.54", "196.10.55.55"]
  }
)

run_list(
  "role[za]"
)
