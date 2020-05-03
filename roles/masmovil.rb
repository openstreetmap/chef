name "masmovil"
description "Role applied to all servers at MásMóvil"

default_attributes(
  :accounts => {
    :users => {
      :osluz => { :status => :administrator }
    }
  },
  :hosted_by => "MásMóvil",
  :location => "Madrid, Spain",
  :networking => {
    :nameservers => ["212.166.64.1", "8.8.8.8"]
  }
)

override_attributes(
  :ntp => {
    :servers => ["0.es.pool.ntp.org", "1.es.pool.ntp.org", "europe.pool.ntp.org"]
  }
)

run_list(
  "role[es]"
)
