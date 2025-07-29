name "ru"
description "Role applied to all servers located in Russia"

override_attributes(
  :country => "ru"
  # :timezone should be be set in parent role for multiple timezone countries
)

run_list(
  "role[base]"
)
