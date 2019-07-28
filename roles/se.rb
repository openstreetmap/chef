name "se"
description "Role applied to all servers located in Sweden"

override_attributes(
  :country => "se",
  :timezone => "Europe/Stockholm"
)

run_list(
  "role[base]"
)
