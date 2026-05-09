name "aws-us-east-2"
description "Role applied to all servers at AWS us-east-2"

default_attributes(
  :location => "Ohio, United States",
  :timezone => "America/New_York"
)

run_list(
  "role[us]",
  "role[aws]"
)
