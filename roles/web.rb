name "web"
description "Role applied to all web/api servers"

default_attributes(
  :accounts => {
    :users => {
      :rails => {
        :status => :role,
        :members => [:tomh, :grant],
      },
    },
  },
  :exim => {
    :trusted_users => ["rails"],
  },
  :passenger => {
    :pool_idle_time => 3600,
  },
  :web => {
    :status => "online",
    :memcached_servers => %w(rails1.ams rails2.ams rails3.ams),
  }
)

run_list(
  "role[web-db]"
)
