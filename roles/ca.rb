name "ca"
description "Role applied to all servers located in Canada"

override_attributes(
  :country => "ca"
)

run_list(
  "role[base]"
)
