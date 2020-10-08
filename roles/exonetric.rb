name "exonetric"
description "Role applied to all servers at Exonetric"

default_attributes(
  :accounts => {
    :users => {
      :hatter => { :status => :administrator }
    }
  },
  :hosted_by => "Exonetric",
  :location => "London, England",
  :networking => {
    :roles => {
      :external => {
        :inet => {
          :prefix => "28",
          :gateway => "178.250.74.33"
        },
        :inet6 => {
          :prefix => "64",
          :gateway => "2a02:1658:4:0::1"
        }
      }
    }
  }
)

run_list(
  "role[gb]"
)
