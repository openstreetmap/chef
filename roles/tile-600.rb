name "tile-600"
description "Role applied to all tile servers running carto 6.0.0"

default_attributes(
  :tile => {
    :database => {
      :output_mode => "flex",
      :tag_transform_script => nil
    },
    :styles => {
      :default => {
        :revision => "v6.0.0",
        :fonts_script => "/srv/tile.openstreetmap.org/styles/default/scripts/get-fonts.py",
        :common_values_script => "/srv/tile.openstreetmap.org/styles/default/common-values.sql",
        :common_values_tables => %w[carto_pois]
      }
    }
  }
)

run_list(
  "role[tile]"
)
