name "elasticsearch"
description "Role applied to all elasticsearch servers"

default_attributes(
  :apt => {
    :sources => ["elasticsearch"]
  }
)

run_list(
  "recipe[elasticsearch]"
)
