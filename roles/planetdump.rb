name "planetdump"
description "Role applied to all planetdump servers"

run_list(
  "recipe[planet::dump]",
  "recipe[planet::dump-notes]"
)
