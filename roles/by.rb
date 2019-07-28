name "by"
description "Role applied to all servers located in Belarus"

override_attributes(
  :country => "by",
  :timezone => "Europe/Minsk"
)

run_list(
  "role[base]"
)
