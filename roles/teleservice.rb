name "teleservice"
description "Role applied to all servers at Teleservice"

default_attributes(
  :hosted_by => "Teleservice Skåne AB",
  :location => "Sjöbo, Sweden"
)

run_list(
  "role[se]"
)
