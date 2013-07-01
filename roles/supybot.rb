name "supybot"
description "Role applied to all supybot servers"

default_attributes(
  :accounts => {
    :users => {
      :supybot => { :status => :role }
    }
  }
)

run_list(
  "recipe[supybot]"
)
