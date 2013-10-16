name "gps-tile"
description "Role applied to all GPS tile servers"

default_attributes(
  :accounts => {
    :users => {
      :enf => { :status => :administrator },
      :gpstile => {
        :status => :role,
        :members => [ :enf, :tomh ]
      }
    }
  }
)

run_list(
  "recipe[memcached]",
  "recipe[gps-tile]"
)
