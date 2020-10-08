name "nchc"
description "Role applied to all servers at NCHC"

default_attributes(
  :accounts => {
    :users => {
      :steven => { :status => :administrator },
      :ceasar => { :status => :administrator }
    }
  },
  :hosted_by => "NCHC",
  :location => "Hsinchu, Taiwan",
  :networking => {
    :wireguard => { :keepalive => 180 }
  }
)

override_attributes(
  :networking => {
    :nameservers => ["140.110.16.1", "140.110.4.1"]
  },
  :ntp => {
    :servers => ["0.tw.pool.ntp.org", "1.tw.pool.ntp.org", "asia.pool.ntp.org"]
  }
)

run_list(
  "role[tw]"
)
