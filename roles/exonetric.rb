name "exonetric"
description "Role applied to all servers at Exonetric"

default_attributes(
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
