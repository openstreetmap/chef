name "ua"
description "Role applied to all servers located in Ukraine"

override_attributes(
  :country => "ua"
)

run_list(
  "role[base]"
)
