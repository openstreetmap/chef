name "prometheus"
description "Role applied to all prometheus servers"

default_attributes(
  :apache => {
    :evasive => false
  }
)

run_list(
  "recipe[awscli]",
  "recipe[prometheus::server]",
  "recipe[prometheus::smokeping]"
)
