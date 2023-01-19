name "lists"
description "Role applied to all mailing list servers"

default_attributes(
  :exim => {
    :aliases => {
      "mailman-loop" => "/dev/null",
      "prometheus" => "/dev/null"
    },
    :local_domains => [
      "openstreetmap.org"
    ]
  }
)

run_list(
  "recipe[mailman]"
)
