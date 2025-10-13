name "pixeldeck"
description "Role applied to all servers at PixelDeck"

default_attributes(
  :hosted_by => "PixelDeck",
  :location => "Kansas City, Missouri",
  :timezone => "US/Central"
)

override_attributes(
  :accounts => {
    :users => {
      :nmoore => { :status => :administrator }
    }
  },
  :ntp => {
    :servers => ["time.pixeldeck.net"]
  }
)

run_list(
  "role[us]"
)
