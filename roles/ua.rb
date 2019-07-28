name "ua"
description "Role applied to all servers located in Ukraine"

override_attributes(
  :country => "ua",
  :timezone => "Europe/Kiev"
)

run_list(
  "role[base]"
)
