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
  :apt => {
    :sources => [ "brightbox-ruby-ng" ]
  },
  :taginfo => {
    :sites => [
      { :name => "taginfo.openstreetmap.org" }
    ]
  }
)

run_list(
  "recipe[taginfo]"
)
