name "epix"
description "Role applied to all servers at EPIX"

default_attributes(
  :hosted_by => "EPIX",
  :location => "Katowice, Poland"
)

run_list(
  "role[pl]"
)
