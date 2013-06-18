name "no"
description "Role applied to all servers located in Norway"

override_attributes(
  :country => "no"
)

run_list(
  "role[base]"
)
