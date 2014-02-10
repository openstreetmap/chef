name "taginfo"
description "Role applied to all taginfo servers"

default_attributes(
  :accounts => {
    :users => {
      :jochen => {
        :status => :administrator
      },
      :taginfo => {
        :status => :role,
        :members => [ :jochen, :tomh ]
      }
    }
  },
  :apache => {
    :mpm => "event",
    :event => {
      :server_limit => 40,
      :max_clients => 1000,
      :min_spare_threads => 50,
      :max_spare_threads => 150,
      :threads_per_child => 50,
      :max_requests_per_child => 10000
    }
  },
  :taginfo => {
    :sites => [
      {
        :name => "taginfo.openstreetmap.org",
        :description => "This is the main taginfo site. It contains OSM data for the whole planet and is updated daily.",
        :icon => "world",
        :contact => "Jochen Topf <jochen@remote.org>"
      }
    ]
  }
)

run_list(
  "recipe[taginfo]"
)
