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
    :pool_idle_time => 0
  },
  :web => {
    :status => "online",
    :memcached_servers => %w(rails1.ic rails2.ic rails3.ic)
  }
)

run_list(
  "role[web-db]"
)
