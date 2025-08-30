name "twds"
description "Role applied to all servers at TWDS"

default_attributes(
  :accounts => {
    :users => {
      :seadog007 => { :status => :administrator }
    }
  },
  :hosted_by => "Taiwan Digital Streaming Co",
  :location => "Taiwan"
)

override_attributes(
  :ntp => {
    :servers => ["0.tw.pool.ntp.org", "1.tw.pool.ntp.org", "asia.pool.ntp.org"]
  }
)

run_list(
  "role[tw]"
)
