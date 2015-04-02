name "munin"
description "Role applied to all munin servers"

default_attributes(
  :munin => {
    :plugins => {
      :munin_update => {
        :contacts => "null"
      }
    }
  }
)

run_list(
  "recipe[munin::server]"
)
