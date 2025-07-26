name "pixeldeck"
description "Role applied to all servers at PixelDeck"

default_attributes(
  :hosted_by => "PixelDeck",
  :location => "Kansas City, Missouri"
)

override_attributes(
  :accounts => {
    :users => {
      :nmoore => { :status => :administrator }
    }
  },
  :networking => {
    :nameservers => ["10.5.7.33", "2602:f629:0:bc::1"]
  },
  :ntp => {
    :servers => ["0.us.pool.ntp.org", "1.us.pool.ntp.org", "north-america.pool.ntp.org"]
  }
)

run_list(
  "role[us]"
)
