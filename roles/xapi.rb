name "xapi"
description "Role applied to all xapi servers"

default_attributes(
  :accounts => {
    :users => {
      :etienne => { :status => :user }
    }
  }
)
