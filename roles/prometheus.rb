name "prometheus"
description "Role applied to all prometheus servers"

run_list(
  "recipe[awscli]",
  "recipe[prometheus::server]",
  "recipe[prometheus::smokeping]"
)
