name "forum"
description "Role applied to all forum servers"

default_attributes(
  :apache => {
    :timeout => 60,
    :keepalive => false,
    :worker => {
      :max_request_workers => 250
    }
  }
)

run_list(
  "recipe[forum]"
)
