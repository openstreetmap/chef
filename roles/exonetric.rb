name "exonetric"
description "Role applied to all servers at Exonetric"

default_attributes(
  :accounts => {
    :users => {
      :hatter => { :status => :administrator }
    }
  },
  :networking => {
    :nameservers => ["8.8.8.8", "8.8.4.4"],
    :roles => {
      :external => {
        :zone => "ex",
        :inet => {
          :prefix => "28",
          :gateway => "178.250.74.33"
        }
      }
    }
  }
)

run_list(
  "role[gb]"
)
