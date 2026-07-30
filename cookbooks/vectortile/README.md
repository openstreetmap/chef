# vectortile cookbook

This cookbook installs and configures the tilekiln based tileservers

## Accounts
The following accounts are used
- `www-data` for nginx serving static files and proxying
- `tilekiln` for the process serving tiles
- `tileupdate` for the process running osm2pgsql and tilekiln on updates
