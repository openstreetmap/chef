name "id"
description "Role applied to all servers located in Indonesia"

override_attributes(
  :country => "id"
)

run_list(
  "role[base]"
)
