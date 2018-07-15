name "web-db"
description "Role applied to all servers needing to find the main database"

default_attributes(
  :web => {
    :database_host => "katla.bm.openstreetmap.org"
  }
)
