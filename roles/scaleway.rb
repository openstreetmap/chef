name "scaleway"
description "Role applied to all servers at Scaleway"

default_attributes(
  :hosted_by => "Scaleway",
  :location => "Paris, France"
)

override_attributes(
  :networking => {
    :nameservers => ["62.210.16.6", "62.210.16.7"]
  }
)

run_list(
  "role[fr]"
)
