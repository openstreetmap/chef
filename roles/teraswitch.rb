name "teraswitch"
description "Role applied to all servers at TeraSwitch Networks"

default_attributes(
  :accounts => {
    :users => {
      :sysadmin => { :status => :administrator }
    }
  },
  :hosted_by => "TeraSwitch Networks",
  :location => "Pittsburgh, Pennsylvania",
  :timezone => "EST5EDT"
)

override_attributes(
  :ntp => {
    :servers => ["0.us.pool.ntp.org", "1.us.pool.ntp.org", "north-america.pool.ntp.org"]
  }
)

run_list(
  "role[us]"
)
