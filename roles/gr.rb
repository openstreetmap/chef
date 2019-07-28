name "gr"
description "Role applied to all servers located in Greece"

override_attributes(
  :country => "gr",
  :timezone => "Europe/Athens"
)

run_list(
  "role[base]"
)
