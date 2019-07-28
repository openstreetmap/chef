name "tw"
description "Role applied to all servers located in Taiwan"

override_attributes(
  :country => "tw",
  :timezone => "Asia/Taipei"
)

run_list(
  "role[base]"
)
