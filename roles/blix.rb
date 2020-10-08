name "blix"
description "Role applied to all servers at Blix"

default_attributes(
  :accounts => {
    :users => {
      :blixadmin => { :status => :administrator }
    }
  },
  :hosted_by => "Blix Solutions"
)
