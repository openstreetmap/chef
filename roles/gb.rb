name "gb"
description "Role applied to all servers located in the UK"

override_attributes(
  :country => "gb",
  :timezone => "Europe/London"
)

run_list(
  "role[base]"
)
