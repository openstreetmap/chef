name "gpx-tile"
description "Role applied to all GPX tile servers"

default_attributes(
  :accounts => {
    :users => {
      :enf => { :status => :administrator }
    }
  }
)
