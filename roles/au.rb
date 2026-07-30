name "au"
description "Role applied to all servers located in Australia"

override_attributes(
  :country => "au"
  # :timezone should be be set in parent role for multiple timezone countries
)

run_list(
  "role[base]"
)
