name "chef-server"
description "Role applied to all chef servers"

run_list(
  "recipe[chef::server]"
)
