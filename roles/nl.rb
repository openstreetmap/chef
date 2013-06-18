name "nl"
description "Role applied to all servers located in the Netherlands"

override_attributes(
  :country => "nl"
)

run_list(
  "role[base]"
)
