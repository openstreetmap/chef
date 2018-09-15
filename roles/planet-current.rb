name "planet-current"
description "Role applied to all servers needing an up to date planet file"

default_attributes(
  :accounts => {
    :users => {
      :planet => {
        :status => :role
      }
    }
  }
)

run_list(
  "recipe[planet::current]"
)
