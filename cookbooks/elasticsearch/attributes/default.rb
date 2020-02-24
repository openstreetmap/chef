default[:elasticsearch][:version] = "6.x"
default[:elasticsearch][:cluster][:name] = "default"
default[:elasticsearch][:cluster][:routing][:allocation][:disk][:watermark][:low] = "85%"
default[:elasticsearch][:cluster][:routing][:allocation][:disk][:watermark][:high] = "90%"
default[:elasticsearch][:cluster][:routing][:allocation][:disk][:watermark][:flood_stage] = "95%"
default[:elasticsearch][:path][:data] = "/var/lib/elasticsearch"

default[:apt][:sources] |= ["elasticsearch#{node[:elasticsearch][:version]}"]
