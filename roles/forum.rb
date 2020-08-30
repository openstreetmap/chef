name "forum"
description "Role applied to all forum servers"

default_attributes(
  :apache => {
    :mpm => "event",
    :timeout => 60,
    :event => {
      :server_limit => 18,
      :max_request_workers => 450,
      :min_spare_threads => 50,
      :max_spare_threads => 150,
      :listen_cores_buckets_ratio => 4
    }
  }
)

run_list(
  "recipe[forum]"
)
