name "es"
description "Role applied to all servers located in Spain"

override_attributes(
  :country => "es",
  :timezone => "Europe/Madrid"
)

run_list(
  "role[base]"
)
