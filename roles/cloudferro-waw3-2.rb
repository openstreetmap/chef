name "cloudferro-waw3-2"
description "Role applied to all servers at CloudFerro WAW3-2"

run_list(
  "role[pl]",
  "role[cloudferro]"
)

default_attributes(
  :location => "Warsaw"
)
