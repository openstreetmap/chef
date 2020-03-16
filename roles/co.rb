name "co"
description "Role applied to all servers located in Colombia"

override_attributes(
  :country => "co",
  :timezone => "America/Bogota"
)

run_list(
  "role[base]"
)
