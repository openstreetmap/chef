name "ar"
description "Role applied to all servers located in Argentina"

override_attributes(
  :country => "ar",
  :timezone => "America/Argentina/Buenos_Aires"
)

run_list(
  "role[base]"
)
