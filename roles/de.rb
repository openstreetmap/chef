name "de"
description "Role applied to all servers located in Germany"

override_attributes(
  :country => "de",
  :timezone => "Europe/Berlin"
)

run_list(
  "role[base]"
)
