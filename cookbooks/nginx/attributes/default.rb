# Tuning for access logging
default[:nginx][:access_log] = "/var/log/nginx/access.log"

# Tuning for nginx fastcgi cache zone
default[:nginx][:cache][:fastcgi][:enable] = false
default[:nginx][:cache][:fastcgi][:directory] = "/var/cache/nginx/fastcgi-cache"
default[:nginx][:cache][:fastcgi][:keys_zone] = "fastcgi_cache_zone:48M"
default[:nginx][:cache][:fastcgi][:inactive] = "45d"
default[:nginx][:cache][:fastcgi][:max_size] = "8192M"

# Tuning for nginx proxy cache zone
default[:nginx][:cache][:proxy][:enable] = false
default[:nginx][:cache][:proxy][:directory] = "/var/cache/nginx/proxy-cache"
default[:nginx][:cache][:proxy][:keys_zone] = "proxy_cache_zone:128M"
default[:nginx][:cache][:proxy][:inactive] = "45d"
default[:nginx][:cache][:proxy][:max_size] = "16384M"

# Enable nginx repository
default[:apt][:sources] = node[:apt][:sources] | ["nginx"]
