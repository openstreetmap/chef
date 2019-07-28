name "hr"
description "Role applied to all servers located in Croatia"

override_attributes(
  :country => "hr",
  :timezone => "Europe/Zagreb"
)

run_list(
  "role[base]"
)
