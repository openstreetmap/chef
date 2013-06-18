name "trac"
description "Role applied to all trac servers"

default_attributes(
  :accounts => {
    :users => {
      :trac => { :status => :role }
    }
  }
)
run_list(
  "recipe[trac]"
)
