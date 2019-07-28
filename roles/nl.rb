name "nl"
description "Role applied to all servers located in the Netherlands"

override_attributes(
  :country => "nl",
  :timezone => "Europe/Amsterdam"
)

run_list(
  "role[base]"
)
