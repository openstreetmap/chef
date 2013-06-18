name "web-gpximport"
description "Role applied to all web/api GPX import servers"

run_list(
  "role[web]",
  "recipe[web::gpx]"
)
