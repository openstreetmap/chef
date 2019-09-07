name "blix"
description "Role applied to all servers at Blix"

default_attributes(
  :accounts => {
    :users => {
      :blixadmin => { :status => :administrator },
    },
  },
  :hosted_by => "Blix Solutions",
  :networking => {
    :nameservers => ["8.8.8.8", "8.8.4.4"],
    :roles => {
      :external => {
        :zone => "bx",
      },
    },
  }
)
