name "stateofthemap"
description "Role applied to State of the Map servers"

run_list(
  "recipe[stateofthemap]",
  "recipe[stateofthemap::jekyll]",
  "recipe[stateofthemap::static]",
  "recipe[stateofthemap::wordpress]"
)
