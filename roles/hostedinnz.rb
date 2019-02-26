name "hostedinnz"
description "Role applied to all servers at HostedIn.NZ"

default_attributes(
  :accounts => {
    :users => {
      :asmith => { :status => :administrator }
    }
  },
  :hosted_by => "HostedIn.NZ",
  :location => "Wellington, New Zealand",
  :networking => {
    :nameservers => ["8.8.8.8", "8.8.4.4"],
    :roles => {
      :external => {
        :zone => "osm"
      }
    }
  },
  :snmpd => {
    :community => "hostedinnz",
    :location => "Wellington"
  }
)

override_attributes(
  :ntp => {
    :servers => ["0.nz.pool.ntp.org", "1.nz.pool.ntp.org", "asia.pool.ntp.org"]
  }
)

run_list(
  "role[nz]",
  "recipe[snmpd]"
)
