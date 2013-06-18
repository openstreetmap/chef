name "ru"
description "Role applied to all servers located in Russia"

override_attributes(
  :country => "ru"
)

run_list(
  "role[base]"
)
