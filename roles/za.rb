name "za"
description "Role applied to all servers located in South Africa"

override_attributes(
  :country => "za"
)

run_list(
  "role[base]"
)
