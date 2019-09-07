name "lists"
description "Role applied to all mailing list servers"

default_attributes(
  :exim => {
    :aliases => {
      "mailman-loop" => "/dev/null",
    },
  }
)

run_list(
  "recipe[mailman]"
)
