$(document).ready(function () {
  // Create a map
  var map = L.map("map").fitBounds([[49.85,-10.5], [58.75, 1.9]]);

  // Create NPE layer
  var npe = L.tileLayer("https://{s}.ooc.openstreetmap.org/npe/{z}/{x}/{y}.png", {
    minZoom: 6,
    maxZoom: 15
  });

  // Create NPE Scotland layer
  var npescotland = L.tileLayer("https://{s}.ooc.openstreetmap.org/npescotland/{z}/{x}/{y}.jpg", {
    minZoom: 6,
    maxZoom: 15
  });

  // Create 7th edition layer
  var os7 = L.tileLayer("https://{s}.ooc.openstreetmap.org/os7/{z}/{x}/{y}.jpg", {
    minZoom: 3,
    maxZoom: 14
  });

  // Create 1st edition layer
  var os1 = L.tileLayer("https://{s}.ooc.openstreetmap.org/os1/{z}/{x}/{y}.jpg", {
    minZoom: 6,
    maxZoom: 17
  });

  // Add OpenStreetMap layer
  var osm = L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
    attribution: "© <a target=\"_parent\" href=\"https://www.openstreetmap.org\">OpenStreetMap</a> and contributors, under an <a target=\"_parent\" href=\"https://www.openstreetmap.org/copyright\">open license</a>",
    maxZoom: 18
  });

  // Create a layer switcher
  var layers = L.control.layers({
    "OS NPE (Eng/Wales 1945-55) 1:50k": npe,
    "OS NPE/7th (Scotland) 1:50k": npescotland,
    "OS 7th Series (1947-60) 1:50k": os7,
    "OS 1st Edition (1946-60) 1:25k": os1,
    "OpenStreetMap": osm
  } , null, {
    collapsed: false
  }).addTo(map);

  // Add the NPE layer to the map
  npe.addTo(map);
});
