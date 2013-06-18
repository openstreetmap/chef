name "us"
description "Role applied to all servers located in the USA"

override_attributes(
  :country => "us"
)

run_list(
  "role[base]"
)
