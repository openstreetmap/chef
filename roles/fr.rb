name "fr"
description "Role applied to all servers located in France"

override_attributes(
  :country => "fr"
)

run_list(
  "role[base]"
)
