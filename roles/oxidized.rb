name "oxidized"
description "Role applied to all oxidized servers"

default_attributes(
  :accounts => {
    :users => {
      :oxidized => {
        :status => :role,
        :members => [:grant, :tomh]
      }
    }
  }
)

run_list(
  "recipe[oxidized]"
)
