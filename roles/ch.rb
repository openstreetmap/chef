name "ch"
description "Role applied to all servers located in Switzerland"

override_attributes(
  :country => "ch",
  :timezone => "Europe/Zurich"
)

run_list(
  "role[base]"
)
