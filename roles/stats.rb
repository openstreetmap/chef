name "stats"
description "Role applied to stats.openstreetmap.org"

default_attributes(
  :stats => {
    :sites => [
      {
        :name => "planet.openstreetmap.org",
        :log_pattern => "%YYYY-168-%MM-168-%DD-168.gz",
        :days => "7"
      },
      {
        :name => "www.openstreetmap.org",
        :log_pattern => "*-%YYYY-48-%MM-48-%DD-48.gz",
        :days => "*"
      }
    ]
  }
)

run_list(
  "recipe[stats]"
)
