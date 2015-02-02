name "thinkup"
description "Role applied to all ThinkUp servers"

default_attributes(
  :accounts => {
    :users => {
      :thinkup => { :status => :role }
    }
  },
  :apache => {
    :mpm => "prefork"
  }
)

run_list(
  "recipe[thinkup]"
)
