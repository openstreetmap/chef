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

run_list(
  "role[tw]"
)
