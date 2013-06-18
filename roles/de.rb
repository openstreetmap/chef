name "de"
description "Role applied to all servers located in Germany"

override_attributes(
  :country => "de"
)

run_list(
  "role[base]"
)
