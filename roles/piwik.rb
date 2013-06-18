name "piwik"
description "Role applied to all Piwik servers"

default_attributes(
  :apache => {
    :mpm => "prefork",
  }
)

run_list(
  "recipe[piwik]"
)
