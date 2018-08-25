name "cplanet"
description "Role applied to servers providing a current planet file"

default_attributes(
  :accounts => {
    :users => {
      :jochen => {
        :status => :administrator
      },
      :cplanet => {
        :status => :role,
        :members => [:jochen, :tomh]
      }
    }
  }
)

run_list(
  "recipe[cplanet]"
)
