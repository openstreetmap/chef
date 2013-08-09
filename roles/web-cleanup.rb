name "web-cleanup"
description "Role applied to all web/api database cleanup servers"

run_list(
  "role[web]",
  "recipe[web::cleanup]"
)
