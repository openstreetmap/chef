name "au"
description "Role applied to all servers located in Australia"

override_attributes(
  :country => "au"
)

run_list(
  "role[base]"
)
