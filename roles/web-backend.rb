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
    :memory_limit => 4096
  },
  :passenger => {
    :max_pool_size => 12
  },
  :web => {
    :rails_soft_memory_limit => 512,
    :rails_hard_memory_limit => 2048
  }
)

run_list(
  "role[web]",
  "recipe[web::backend]"
)
