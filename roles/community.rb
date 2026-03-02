name "community"
description "Role applied to all community servers"

default_attributes(
  :accounts => {
    :groups => {
      :commnunity => {
        :members => [:grant, :tomh]
      }
    }
  }
)

run_list(
  "recipe[community]"
)
