name "lu"
description "Role applied to all servers located in Luxembourg"

override_attributes(
  :country => "lu",
  :timezone => "Europe/Luxembourg"
)

run_list(
  "role[base]"
)
