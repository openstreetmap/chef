name "nz"
description "Role applied to all servers located in New Zealand"

override_attributes(
  :country => "nz",
  :timezone => "Pacific/Auckland"
)

run_list(
  "role[base]"
)
