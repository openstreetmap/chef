name "blix"
description "Role applied to all servers at Blix"

default_attributes(
  :accounts => {
    :users => {
      :blixadmin => { :status => :administrator }
    }
  },
  :networking => {
    :nameservers => [ "8.8.8.8", "8.8.4.4" ],
    :roles => {
      :external => {
        :zone => "bx"
      }
    }
  }
)
