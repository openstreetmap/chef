name "birthday20"
description "Role applied to birthday20 servers"

default_attributes(
  :accounts => {
    :users => {
      :mikel => { :status => :administrator },
      :wordpress => {
        :status => :role,
        :members => [:mikel]
      }
    },
  }
)

run_list(
  "recipe[blog::birthday]"
)
