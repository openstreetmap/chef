name "ie"
description "Role applied to all servers located in Ireland"

override_attributes(
  :country => "ie",
  :timezone => "Europe/Dublin"
)

run_list(
  "role[base]"
)
