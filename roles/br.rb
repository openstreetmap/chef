name "br"
description "Role applied to all servers located in Brazil"

override_attributes(
  :country => "br"
)

run_list(
  "role[base]"
)
