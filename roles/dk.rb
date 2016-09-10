name "dk"
description "Role applied to all servers located in Denmark"

override_attributes(
  :country => "dk"
)

run_list(
  "role[base]"
)
