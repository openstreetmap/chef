name "letsencrypt"
description "Role applied to all letsencrypt servers"

run_list(
  "recipe[letsencrypt]"
)
