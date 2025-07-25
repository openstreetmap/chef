# OpenStreetMap chef cookbooks

[![Cookstyle](https://github.com/openstreetmap/chef/actions/workflows/cookstyle.yml/badge.svg)](https://github.com/openstreetmap/chef/actions/workflows/cookstyle.yml)
[![Test Kitchen](https://github.com/openstreetmap/chef/actions/workflows/test-kitchen.yml/badge.svg)](https://github.com/openstreetmap/chef/actions/workflows/test-kitchen.yml)

This repository manages the configuration of all the servers run by the
OpenStreetMap Foundation's Operations Working Group. We use
[Chef](https://www.chef.io/) to automate the configuration of all of our
servers.

[OSMF Operations Working Group](https://operations.osmfoundation.org/)

# Roles

We make extensive use of roles to configure the servers. In general we have:

## Server-specific roles (e.g., [faffy.rb](roles/faffy.rb))

These deal with particular setup or quirks of a server, such as its IP address. They also include roles representing the service they are performing, and the location they are in and any particular hardware they have that needs configuration.
All our servers are [named after dragons](https://wiki.openstreetmap.org/wiki/Servers/Name_Ideas).

## Hardware-specific roles (e.g., [hp-g9.rb](roles/hp-g9.rb))

Covers anything specific to a certain piece of hardware, like a motherboard, that could apply to multiple machines.

## Location-specific roles (e.g., [equinix-dub.rb](roles/equinix-dub.rb))

These form a hierarchy of datacentres, organisations, and countries where our servers are located.

## Service-specific roles (e.g., [web-frontend](roles/web-frontend.rb))

These cover the services that the server is running, and will include the recipes required for that service along with any specific configurations and other cascading roles.

# Cookbooks

We use the 'Organization Repository' approach, where we have all our cookbooks in this repository (as opposed to one repository per cookbook). Additionally we don't make use of external cookbooks so every cookbook required is in this repository.

# Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for more details. The guide also includes details on how to run the tests locally.

# Contact Us

* Mastodon: [@osm_tech](https://en.osm.town/@osm_tech)
* IRC: [#osm-dev on irc.oftc.net](https://irc.openstreetmap.org/) or [#osmf-operations on irc.oftc.net](https://irc.openstreetmap.org/)
* Matrix: [#\_oftc_#osmf-operations](https://matrix.to/#/#_oftc_#osmf-operations:matrix.org)
* Email: [operations@osmfoundation.org](mailto:operations@osmfoundation.org)
