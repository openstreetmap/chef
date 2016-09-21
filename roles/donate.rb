name "donate"
description "Role applied to all donate servers"

default_attributes(
  :accounts => {
    :users => {
      :donate => {
        :status => :role,
        :members => [:grant, :tomh, :matt]
      }
    }
  }
)

run_list(
  "recipe[donate]"
)
