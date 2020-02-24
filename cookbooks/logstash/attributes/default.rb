default[:logstash][:forwarder]["output.logstash"]["hosts"] = ["logstash.openstreetmap.org:5044"]
default[:logstash][:forwarder]["output.logstash"]["ssl.certificate_authorities"] = "/etc/filebeat/filebeat.crt"
default[:logstash][:forwarder]["output.logstash"]["ssl.verification_mode"] = "none"
default[:logstash][:forwarder]["filebeat.prospectors"] = []

default[:elasticsearch][:cluster][:name] = "logstash"
