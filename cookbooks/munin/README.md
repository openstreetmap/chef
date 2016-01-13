# Munin Cookbook

This cookbook configures munin, which we use for server monitoring at
[munin.openstreetmap.org](http://munin.openstreetmap.org). The cookbook
contains two recipes:

* default - installs and configures munin-node on each machine.
* server - configures the central munin server

Additionally two providers are defined - munin_plugin and munin_plugin_conf, for
configuring individual munin plugins.
