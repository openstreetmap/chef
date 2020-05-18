# Use prefork as PHP is to dumb for anything else
override[:apache][:mpm] = "prefork"
