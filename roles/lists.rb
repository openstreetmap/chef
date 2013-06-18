name "lists"
description "Role applied to all mailing list servers"

run_list(
  "recipe[mailman]"
)
