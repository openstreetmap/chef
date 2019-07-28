name "cz"
description "Role applied to all servers located in the Czech Republic"

override_attributes(
  :country => "cz",
  :timezone => "Europe/Prague"
)

run_list(
  "role[base]"
)
