name "tetaneutral"
description "Role applied to all servers at Tetaneutral.net"

default_attributes(
  :accounts => {
    :users => {
      :tetaneutral => { :status => :administrator },
    },
  },
  :hosted_by => "Tetaneutral.net",
  :location => "Toulouse, France",
  :networking => {
    :nameservers => [
      "8.8.8.8",
      "8.8.4.4",
    ],
    :roles => {
      :external => {
        :zone => "tnn",
      },
    },
  }
)

override_attributes(
  :ntp => {
    :servers => ["0.fr.pool.ntp.org", "1.fr.pool.ntp.org", "europe.pool.ntp.org"],
  }
)

run_list(
  "role[fr]"
)
