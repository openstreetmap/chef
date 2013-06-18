name "racs"
description "Role applied to all servers at Roy Adams Computer Services"

default_attributes(
  :accounts => {
    :users => {
      :kamy => { :status => :administrator }
    }
  },
  :networking => {
    :nameservers => [ "8.8.8.8", "8.8.4.4" ],
    :roles => {
      :external => {
        :zone => "ra"
      }
    }
  }
)

override_attributes(
  :ntp => {
    :servers => [ "0.au.pool.ntp.org", "1.au.pool.ntp.org", "oceania.pool.ntp.org" ]
  }
)

run_list(
  "role[au]"
)
