imagery_site "ea.openstreetmap.org.uk" do
  title "OpenStreetMap - Environment Agency OpenData"
  bbox [[49.85, -10.5], [58.75, 1.9]]
end

imagery_layer "gb_ea_night" do
  site "ea.openstreetmap.org.uk"
  title "Environment Agency - Night Time Aerial"
  projection "EPSG:27700"
  source "/data/imagery/gb/ea/night/ea-night.vrt"
  copyright "&copy; Environment Agency copyright and/or database right 2016. All rights reserved."
  background_colour "0 0 0"
  extension "os_sv_png"
end
