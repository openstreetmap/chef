# Z-shell options
setopt EXTENDED_GLOB
setopt RC_EXPAND_PARAM

# Set file creation mask
umask 002

# No core dumps
limit coredumpsize 0

# Set the function search path
FPATH=${HOME}/zshfuncs:${FPATH}

# Export the host name
export HOST

# Get the unqualified node name for this host
NODE="${(M)HOST##[^.]##}"
