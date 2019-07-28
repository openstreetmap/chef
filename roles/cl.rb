name "cl"
description "Role applied to all servers located in Chile"

override_attributes(
  :country => "cl",
  :timezone => "America/Santiago"
)

run_list(
  "role[base]"
)
