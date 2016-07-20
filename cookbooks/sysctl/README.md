# sysctl cookbook

This cookbook allows various sysctl settings to be controlled via attributes.
Settings can be added to node[:sysctl] attribute, and these are both updated
via `/proc/sys` and added to a template in `/etc/sysctl.d/`
