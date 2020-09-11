name "prometheus"
description "Role applied to all prometheus servers"

run_list(
  "recipe[prometheus::server]"
)
