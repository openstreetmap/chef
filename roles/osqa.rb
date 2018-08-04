name "osqa"
description "Role applied to all OSQA servers"

default_attributes(
  :accounts => {
    :users => {
      :osqa => { :status => :role }
    }
  },
  :osqa => {
    :sites => [
      { :name => "help.openstreetmap.org",
        :aliases => ["help.osm.org"],
        :backup => "osqa" }
    ]
  }
)

run_list(
  "recipe[osqa]"
)
