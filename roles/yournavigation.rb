name "yournavigation"
description "Role applied to all yournavigation servers"

default_attributes(
  :accounts => {
    :users => {
      :lambertus => { :status => :administrator }
    }
  },
  :apache => {
    :mpm => "prefork",
    :timeout => 60,
    :keepalive => false,
    :prefork => {
      :start_servers => 20,
      :min_spare_servers => 20,
      :max_spare_servers => 50,
      :max_clients => 256,
    }
  }
)

run_list(
  "recipe[yournavigation]"
)
