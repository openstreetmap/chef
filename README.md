# OpenStreetMap chef cookbooks

[![Cookstyle](https://github.com/openstreetmap/chef/workflows/Cookstyle/badge.svg?branch=master&event=push)](https://github.com/openstreetmap/chef/actions?query=workflow%3ACookstyle%20branch%3Amaster%20event%3Apush)
[![Test Kitchen](https://github.com/openstreetmap/chef/workflows/Test%20Kitchen/badge.svg?branch=master&event=push)](https://github.com/openstreetmap/chef/actions?query=workflow%3A%22Test+Kitchen%22%20branch%3Amaster%20event%3Apush)

This repository manages the configuration of all the servers run by the
OpenStreetMap Foundation's Operations Working Group. We use
[Chef](https://www.chef.io/) to automated the configuration of all of our
servers.

[OSMF Operations Working Group](https://operations.osmfoundation.org/)

# Roles

We make extensive use of roles to configure the servers. In general we have:

## Server-specific roles (e.g. [katla.rb](roles/katla.rb))

These deal with particular setup or quirks of a server, such as its IP address. They also include roles representing the service they are performing, and the location they are in and any particular hardware they have that needs configuration.
All our servers are [named after dragons](https://wiki.openstreetmap.org/wiki/Servers/Name_Ideas).

## Hardware-specific roles (e.g. [tyan-s7010.rb](roles/tyan-s7010.rb))

Covers anything specific to a certain piece of hardware, like a motherboard, that could apply to multiple machines.

## Location-specific roles (e.g. [equinix.rb](roles/equinix.rb))

These form a hierarchy of datacentres, organisations, and countries where our servers are located.

## Service-specific roles (e.g. [web-frontend](roles/web-frontend.rb))

These cover the services that the server is running, and will include the recipes required for that service along with any specific configurations and other cascading roles.

# Cookbooks

We use the 'Organization Repository' approach, where we have all our cookbooks in this repository (as opposed to one repository per cookbook). Additionally we don't make use of external cookbooks so every cookbook required is in this repository.

# Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for more details.

# Contact Us

* Twitter: [@OSM_Tech](https://twitter.com/OSM_Tech)
* IRC: [#OSM-Dev on irc.oftc.net](https://irc.openstreetmap.org/)
