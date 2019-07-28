name "dk"
description "Role applied to all servers located in Denmark"

override_attributes(
  :country => "dk",
  :timezone => "Europe/Copenhagen"
)

run_list(
  "role[base]"
)
