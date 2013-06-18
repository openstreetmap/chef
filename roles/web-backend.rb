name "web-backend"
description "Role applied to all web/api backend servers"

default_attributes(
  :apache => {
    :mpm => "worker",
    :worker => {
      :max_requests_per_child => 10000
    }
  },
  :memcached  => {
    :memory_limit => 512
  },
  :web => {
    :rails_daemon_limit => 12,
    :rails_soft_memory_limit => 512,
    :rails_hard_memory_limit => 2048
  }
)

run_list(
  "role[web]",
  "recipe[web::backend]"
)
