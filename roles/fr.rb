name "fr"
description "Role applied to all servers located in France"

override_attributes(
  :country => "fr",
  :timezone => "Europe/Paris"
)

run_list(
  "role[base]"
)
