name "stateofthemap"
description "Role applied to State of the Map servers"

default_attributes(
  :accounts => {
    :users => {
      :stateofthemap => {
        :status => :role,
        :members => [:grant, :tomh]
      }
    }
  }
)

run_list(
  "recipe[stateofthemap]"
)
