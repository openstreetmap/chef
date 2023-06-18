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
    :compression_mode => "lz4",
    :restricted_api => true
  },
  :prometheus => {
    :files => %w[
      /srv/query.openstreetmap.org/diffs/latest.osc
    ]
  }
)

run_list(
  "recipe[overpass::default]"
)
