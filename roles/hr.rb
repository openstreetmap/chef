name "hr"
description "Role applied to all servers located in Croatia"

override_attributes(
  :country => "hr"
)

run_list(
  "role[base]"
)
