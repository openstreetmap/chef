name "hu"
description "Role applied to all servers located in Hungary"

override_attributes(
  :country => "hu"
)

run_list(
  "role[base]"
)
