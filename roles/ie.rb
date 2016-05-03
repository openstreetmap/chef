name "ie"
description "Role applied to all servers located in Ireland"

override_attributes(
  :country => "ie"
)

run_list(
  "role[base]"
)
