# Prometheus Cookbook

This cookbook configures prometheus, which we use for server monitoring at
[prometheus.openstreetmap.org](https://prometheus.openstreetmap.org). The
cookbook contains two recipes:

* default - installs and configures basic prometheus exporters on each machine
* server - configures the central prometheus server

Additionally two providers are defined - prometheus_exporter and
prometheus_textfile_exporter, for configuring individual prometheus
exporters.
