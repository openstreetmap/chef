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
