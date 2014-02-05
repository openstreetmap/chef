function createMap(divName, jsonFile) {
  // Create a map
  var map = L.map(divName);

  // Add OpenStreetMap layer
  L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
    attribution: "© <a target=\"_parent\" href=\"http://www.openstreetmap.org\">OpenStreetMap</a> and contributors, under an <a target=\"_parent\" href=\"http://www.openstreetmap.org/copyright\">open license</a>",
    maxZoom: 18
  }).addTo(map);

  // Add the JSON file as an overlay
  $.ajax({
    url: jsonFile,
    success: function(json) {
      var jsonLayer = L.geoJson(json, {
        style: function(feature) {
          return { color: feature.properties.colour, weight: 2, opacity: 1 }
        },
        onEachFeature: function (feature, layer) {
          layer.bindPopup(feature.properties.origin + " via " + feature.properties.server);
          layer.on("mouseover", function () {
            this.setStyle({ weight: 5 });
          });
          layer.on("mouseout", function () {
            this.setStyle({ weight: 2 });
          });
        }
      }).addTo(map);

      map.fitBounds(jsonLayer.getBounds());
    }
  });

  return map;
}
