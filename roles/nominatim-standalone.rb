name "nominatim-standalone"
description "Role applied to all stand-alone nominatim servers"

default_attributes(
  :postgresql => {
    :versions => ["9.3"]
  },
  :nominatim => {
    :enable_backup => false
  }

)

run_list(
  "role[nominatim]",
  "recipe[nominatim::standalone]"
)
