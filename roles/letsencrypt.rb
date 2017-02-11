name "letsencrypt"
description "Role applied to all letsencrypt servers"

default_attributes(
  :accounts => {
    :users => {
      :letsencrypt => {
        :status => :role
      }
    }
  }
)

run_list(
  "recipe[letsencrypt]"
)
