name "grifon"
description "Role applied to all servers at Grifon"

default_attributes(
  :accounts => {
    :users => {
      :alarig => { :status => :administrator },
      :gizmo => { :status => :administrator },
      :nemo => { :status => :administrator }
    }
  },
  :hosted_by => "Grifon",
  :location => "Rennes, France",
  :munin => {
    :allow => ["2a00:5884::8"]
  },
  :networking => {
    :firewall => {
      :inet6 => [
        {
          :action => "ACCEPT",
          :source => "net:[2a00:5884::8]",
          :dest => "fw",
          :proto => "tcp",
          :dest_ports => "munin",
          :source_ports => "1024:",
          :rate_limit => "-",
          :connection_limit => "-"
        }
      ]
    }
  }
)

override_attributes(
  :ntp => {
    :servers => ["0.fr.pool.ntp.org", "1.fr.pool.ntp.org", "europe.pool.ntp.org"]
  }
)

run_list(
  "role[fr]"
)
