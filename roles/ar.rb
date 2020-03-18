name "ar"
description "Role applied to all servers located in Argentina"

override_attributes(
  :country => "ar"
)

run_list(
  "role[base]"
)
