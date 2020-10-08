name "grnet"
description "Role applied to all servers at GRNET"

default_attributes(
  :accounts => {
    :users => {
      :grnet => { :status => :administrator }
    }
  },
  :hosted_by => "GRNET",
  :location => "Athens, Greece"
)

override_attributes(
  :ntp => {
    :servers => ["0.gr.pool.ntp.org", "1.gr.pool.ntp.org", "europe.pool.ntp.org"]
  }
)

run_list(
  "role[gr]"
)
