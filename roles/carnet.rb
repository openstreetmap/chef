name "carnet"
description "Role applied to all servers at CARNet"

default_attributes(
  :accounts => {
    :users => {
      :hbogner => { :status => :administrator }
    }
  },
  :hosted_by => "CARNet"
)

run_list(
  "role[hr]"
)
