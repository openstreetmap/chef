name "lyonix"
description "Role applied to all servers at LyonIX"

default_attributes(
  :accounts => {
    :users => {
      :lyonix => { :status => :administrator }
    }
  },
  :networking => {
    :nameservers => [ "77.95.64.205", "77.95.64.206", "8.8.8.8", "8.8.4.4" ],
    :roles => {
      :external => {
        :zone => "ly"
      }
    }
  }
)

override_attributes(
  :ntp => {
    :servers => [ "0.fr.pool.ntp.org", "1.fr.pool.ntp.org", "europe.pool.ntp.org" ]
  }
)

run_list(
  "role[fr]"
)
