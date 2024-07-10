name "web-db"
description "Role applied to all servers needing to find the main database"

default_attributes(
  :web => {
    :database_host => "snap-01.ams.openstreetmap.org"
  }
)
