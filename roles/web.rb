name "web"
description "Role applied to all web/api servers"

default_attributes(
  :accounts => {
    :users => {
      :rails => {
        :status => :role,
        :members => [:tomh, :grant]
      }
    }
  },
  :passenger => {
    :pool_idle_time => 3600
  },
  :web => {
    :status => "database_readonly",
    :memcached_servers => %w[rails4.bm rails5.bm]
  }
)

run_list(
  "role[web-db]"
)
