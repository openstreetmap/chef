name "kibana"
description "Role applied to all kibana servers"

default_attributes(
  :accounts => {
    :users => {
      :kibana => { :status => :role }
    }
  }
)

run_list(
  "recipe[kibana]"
)
