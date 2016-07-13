# OpenStreetMap chef cookbooks

[![Build Status](https://travis-ci.org/openstreetmap/chef.svg?branch=master)](https://travis-ci.org/openstreetmap/chef)

This repository manages the configuration of all the servers run by the
OpenStreetMap Foundation's Operations Working Group. We use
[Chef](https://www.chef.io/) to automated the configuration of all of our
servers.

# Roles

We make extensive use of roles to configure the servers. In general we have:

## Server-specific roles (e.g. [katla.rb](roles/katla.rb))

These deal with particular setup or quirks of a server, such as its IP address. They also include roles representing the service they are performing, and the location they are in and any particular hardware they have that needs configuration.
All our servers are [named after dragons](http://wiki.openstreetmap.org/wiki/Servers/Name_Ideas).

## Hardware-specific roles (e.g. [tyan-s7010.rb](roles/tyan-s7010.rb))

Covers anything specific to a certain piece of hardware, like a motherboard, that could apply to multiple machines.

## Location-specific roles (e.g. [ic.rb](roles/ic.rb))

These form a hierarchy of datacentres, organisations, and countries where our servers are located.

## Service-specific roles (e.g. [web-frontend](roles/web-frontend.rb))

These cover the services that the server is running, and will include the recipes required for that service along with any specific configurations and other cascading roles.

# Cookbooks

We use the 'Organization Repository' approach, where we have all our cookbooks in this repository (as opposed to one repository per cookbook). Additionally we don't make use of external cookbooks so every cookbook required is in this repository.

# Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for more details.
