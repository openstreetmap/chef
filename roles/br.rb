name "br"
description "Role applied to all servers located in Brazil"

override_attributes(
  :country => "br"
  # :timezone should be be set in parent role for multiple timezone countries
)

run_list(
  "role[base]"
)
