name "web-statistics"
description "Role applied to all web/api statistics generation servers"

run_list(
  "role[web]",
  "recipe[web::statistics]"
)
