name "apt"
description "Role applied to APT repositories"

run_list(
  "recipe[apt::repository]"
)
