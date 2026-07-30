name "blogs"
description "Role applied to all blog aggregators"

default_attributes(
  :ruby => {
    :version => "3.3"
  }
)

run_list(
  "recipe[blogs]"
)
