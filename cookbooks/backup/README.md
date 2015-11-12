# Backup Cookbook

This cookbook is run on the machine that stores the central backups. It creates
the store for the backups and manages their expiry. It also configures the rsync
daemon used by machines that send in their backups.
