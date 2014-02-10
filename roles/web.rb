name "web"
description "Role applied to all web/api servers"

default_attributes(
  :accounts => {
    :users => {
      :rails => {
        :status => :role,
        :members => [ :tomh, :grant ]
      }
    }
  },
  :nfs => {
    "/store/rails" => { :host => "ironbelly", :path => "/store/rails" }
  },
  :passenger => {
    :pool_idle_time => 0
  },
  :web => {
    :status => "online",
    :database_host => "db",
    :readonly_database_host => "katla"
  }
)

run_list(
  "recipe[nfs]"
)
