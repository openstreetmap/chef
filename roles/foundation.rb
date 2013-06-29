name "foundation"
description "Role applied to all OSMF servers"

default_attributes(
  :apache => {
    :mpm => "prefork",
    :timeout => 60,
    :keepalive => false
  },
  :apt => {
    :sources => [ "brightbox", "aw-drupal" ]
  },
  :memcached => {
    :memory_limit => 400,
    :chunk_growth_factor => 1.05,
    :min_item_size => 5
  }
)

run_list(
  "recipe[civicrm]"
)
