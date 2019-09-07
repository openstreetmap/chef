name "unizar"
description "Role applied to all servers at University of Zaragoza"

default_attributes(
  :accounts => {
    :users => {
      :osluz => { :status => :administrator },
    },
  },
  :hosted_by => "University of Zaragoza",
  :location => "Zaragoza, Spain",
  :networking => {
    :nameservers => ["155.210.12.9", "155.210.3.12"],
    :roles => {
      :external => {
        :zone => "uz",
      },
    },
  }
)

override_attributes(
  :ntp => {
    :servers => ["0.es.pool.ntp.org", "1.es.pool.ntp.org", "europe.pool.ntp.org"],
  }
)

run_list(
  "role[es]"
)
