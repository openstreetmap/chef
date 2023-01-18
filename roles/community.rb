name "community"
description "Role applied to all community servers"

default_attributes(
  :accounts => {
    :users => {
      :community => {
        :status => :role,
        :members => [:grant, :tomh]
      }
    }
  }
)

run_list(
  "recipe[community]"
)
