default[:apache][:mpm] = "event"

default[:apache][:timeout] = 300

default[:apache][:keepalive] = true

default[:apache][:prefork][:start_servers] = 5
default[:apache][:prefork][:min_spare_servers] = 5
default[:apache][:prefork][:max_spare_servers] = 10
default[:apache][:prefork][:max_request_workers] = 150
default[:apache][:prefork][:max_connections_per_child] = 0

default[:apache][:worker][:start_servers] = 2
default[:apache][:worker][:min_spare_threads] = 25
default[:apache][:worker][:max_spare_threads] = 75
default[:apache][:worker][:thread_limit] = 64
default[:apache][:worker][:threads_per_child] = 25
default[:apache][:worker][:max_request_workers] = 150
default[:apache][:worker][:max_connections_per_child] = 0

default[:apache][:event][:start_servers] = 2
default[:apache][:event][:min_spare_threads] = 25
default[:apache][:event][:max_spare_threads] = 75
default[:apache][:event][:thread_limit] = 64
default[:apache][:event][:threads_per_child] = 25
default[:apache][:event][:max_request_workers] = 150
default[:apache][:event][:max_connections_per_child] = 0

default[:apache][:listen_address] = "*"

default[:apache][:buffered_logs] = true

default[:apache][:reqtimeout] = false
