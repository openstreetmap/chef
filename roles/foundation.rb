name "foundation"
description "Role applied to all OSMF servers"

default_attributes(
  :apache => {
    :mpm => "prefork",
    :timeout => 60,
    :keepalive => false
  },
  :apt => {
    :sources => ["passenger"]
  },
  :elasticsearch => {
    :cluster => {
      :name => "foundation"
    },
    :script => {
      :disable_dynamic => false
    }
  },
  :memcached => {
    :memory_limit => 400,
    :chunk_growth_factor => 1.05,
    :min_item_size => 5
  }
)

run_list(
  "role[crm]",
  "role[elasticsearch]",
  "recipe[foundation::wiki]",
  "recipe[foundation::board]"
)
