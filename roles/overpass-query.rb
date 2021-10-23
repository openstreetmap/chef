name "overpass-query"
description "Role applied to overpass servers for the query feature."

default_attributes(
  :accounts => {
    :users => {
      :lonvia => { :status => :administrator },
      :overpass => {
        :status => :role,
        :members => [:lonvia, :tomh]
      }
    }
  },
  :overpass => {
    :fqdn => "query.openstreetmap.org",
    :meta_mode => "no",
    :compression_mode => "no",
    :restricted_api => true
  }
)

run_list(
  "recipe[overpass::default]"
)
