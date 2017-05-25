name "gr"
description "Role applied to all servers located in Greece"

override_attributes(
  :country => "gr"
)

run_list(
  "role[base]"
)
