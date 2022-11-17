name "community"
description "Role applied to all community servers"

default_attributes(
  :accounts => {
    :users => {
      :community => {
        :status => :role,
        :members => [:grant, :tomh]
      }
    }
  },
  :exim => {
    :smarthost_via => "fafnir.openstreetmap.org:26"
  }
)

run_list(
  "recipe[community]"
)
