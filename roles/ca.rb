name "ca"
description "Role applied to all servers located in Canada"

override_attributes(
  :country => "ca"
  # :timezone should be set in parent role for multiple timezone countries
)

run_list(
  "role[base]"
)
