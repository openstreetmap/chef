$(document).ready(function () {
  // Create a map
  var map = L.map("map");

  // Add GPS tile layer
  L.tileLayer("//gps-{s}.tile.openstreetmap.org/gps-lines/tile/{z}/{x}/{y}.png", {
    attribution: "© <a target=\"_parent\" href=\"https://www.openstreetmap.org\">OpenStreetMap</a> and contributors, under an <a target=\"_parent\" href=\"https://www.openstreetmap.org/copyright\">open license</a>",
    maxZoom: 18
  }).addTo(map);

  // SHow the whole world
  map.fitWorld();
});
