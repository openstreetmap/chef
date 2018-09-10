name "export"
description "Role applied to servers exporting OSM data in various formats"

default_attributes(
  :accounts => {
    :users => {
      :jochen => {
        :status => :administrator
      },
      :export => {
        :status => :role,
        :members => [:jochen, :tomh]
      }
    }
  }
)

run_list(
  "recipe[export]"
)
