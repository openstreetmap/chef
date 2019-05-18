name "cz"
description "Role applied to all servers located in the Czech Repuclib"

override_attributes(
  :country => "cz"
)

run_list(
  "role[base]"
)
