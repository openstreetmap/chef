# db Cookbook

This cookbook installs and configures the PostgreSQL database required by the
openstreetmap-website (aka Rails Port) codebase.

There are four recipes available:

* backup: configures the pg_dump-based backups and rsyncing to the backup server.
* base: installs the database and rails port codebase.
* master: configuration of user accounts etc that happen on the master server.
* slave: placeholder for slave database configuration.
