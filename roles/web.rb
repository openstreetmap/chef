name "web"
description "Role applied to all web/api servers"

default_attributes(
  :accounts => {
    :users => {
      :rails => {
        :members => [:tomh, :grant]
      }
    }
  },
  :exim => {
    :trusted_users => ["rails"]
  },
  :passenger => {
    :pool_idle_time => 3600
  },
  :web => {
    :status => "online",
    :memcached_servers => %w[spike-06.ams spike-07.ams spike-08.ams]
  }
)

run_list(
  "role[web-db]"
)
