name "pl"
description "Role applied to all servers located in Poland"

override_attributes(
  :country => "pl",
  :timezone => "Europe/Warsaw"
)

run_list(
  "role[base]"
)
