name "us"
description "Role applied to all servers located in the USA"

override_attributes(
  :country => "us"
  # :timezone should be be set in parent role for multiple timezone countries
)

run_list(
  "role[base]"
)
