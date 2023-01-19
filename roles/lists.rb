name "lists"
description "Role applied to all mailing list servers"

default_attributes(
  :exim => {
    :aliases => {
      "mailman-loop" => "/dev/null"
    },
    :local_domain => [
      "openstreetmap.org"
    ]
  }
)

run_list(
  "recipe[mailman]"
)
