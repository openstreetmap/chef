# web cookbook

This cookbook installs and configures the web frontend machines that power
[www.openstreetmap.org](https://www.openstreetmap.org). There are several recipes

* `web::base` - sets up common storage configuration between all the machines
* `web::cgimap` - builds and configures [cgimap](https://github.com/openstreetmap/cgimap)
* `web::cleanup` - configures a cleanup script to be run daily
* `web::frontend` - sets up the frontend servers, that handle all inbound requests
* `web::gpx` - sets up the GPX importer
* `web::rails` - installs and configures the [openstreetmap-website](https://github.com/openstreetmap/openstreetmap-website) rails app
* `web::statistics` - sets up the scripts for generating the [statistics page](https://www.openstreetmap.org/stats/data_stats.html) for OSM contributions
