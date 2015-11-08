name "exonetric"
description "Role applied to all servers at Exonetric"

default_attributes(
  :accounts => {
    :users => {
      :hatter => { :status => :administrator }
    }
  },
  :networking => {
    :roles => {
      :external => {
        :zone => "ex"
      }
    }
  }
)

run_list(
  "role[gb]"
)
