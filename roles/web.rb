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
    :status => "database_readonly",
    :memcached_servers => %w[spike-01.dub spike-02.dub spike-03.dub]
  }
)

run_list(
  "role[web-db]"
)
