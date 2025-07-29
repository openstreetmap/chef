name "id"
description "Role applied to all servers located in Indonesia"

override_attributes(
  :country => "id"
  # :timezone should be be set in parent role for multiple timezone countries
)

run_list(
  "role[base]"
)
