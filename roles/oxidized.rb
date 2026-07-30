name "oxidized"
description "Role applied to all oxidized servers"

default_attributes(
  :accounts => {
    :groups => {
      :oxidized => {
        :members => [:grant, :tomh]
      }
    }
  }
)

run_list(
  "recipe[oxidized]"
)
