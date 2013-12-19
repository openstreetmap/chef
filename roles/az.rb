name "az"
description "Role applied to all servers located in Azerbaijan"

override_attributes(
  :country => "az"
)

run_list(
  "role[base]"
)
