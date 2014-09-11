name "carnet"
description "Role applied to all servers at CARNet"

default_attributes(
  :accounts => {
    :users => {
      :anovak => { :status => :administrator },
      :hbogner => { :status => :administrator }
    }
  },
  :networking => {
    :nameservers => [ "2001:b68:ff:1::2", "2001:b68:ff:2::2", "2001:4860:4860::8888" ],
    :roles => {
      :external => {
        :zone => "cnt"
      }
    }
  }
)

override_attributes(
  :ntp => {
    :servers => [ "0.hr.pool.ntp.org", "1.hr.pool.ntp.org", "europe.pool.ntp.org" ]
  }
)

run_list(
  "role[hr]"
)
