name "munin"
description "Role applied to all munin servers"

run_list(
  "recipe[munin::server]"
)
