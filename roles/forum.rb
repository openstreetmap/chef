name "forum"
description "Role applied to all forum servers"

default_attributes(
  :accounts => {
    :users => {
      :lambertus => {
        :status => :administrator
      },
      :forum => {
        :status => :role,
        :members => [:lambertus, :grant]
      }
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
      :max_request_workers => 256
    }
  }
)

run_list(
  "recipe[forum]"
)
