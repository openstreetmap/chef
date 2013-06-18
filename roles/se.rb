name "se"
description "Role applied to all servers located in Sweden"

override_attributes(
  :country => "se"
)

run_list(
  "role[base]"
)
