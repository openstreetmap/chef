default[:logstash][:forwarder][:network][:servers] = ["logstash.openstreetmap.org:5043"]
default[:logstash][:forwarder][:network][:"ssl ca"] = "/var/lib/logstash-forwarder/lumberjack.crt"
default[:logstash][:forwarder][:files] = []
