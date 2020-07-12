# Enable the "forum" role
default[:accounts][:users][:forum][:status] = :role

# Configure PHP options
default[:php][:fpm][:options][:open_basedir] = "/srv/forum.openstreetmap.org/html/:/usr/share/php/:/tmp/"
default[:php][:fpm][:options][:disable_functions] = "exec,shell_exec,system,passthru,popen,proc_open"
default[:php][:fpm][:options][:upload_max_filesize] = "70M"
default[:php][:fpm][:options][:post_max_size] = "100M"
