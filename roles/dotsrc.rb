name "dotsrc"
description "Role applied to all servers at dotsrc.org"

default_attributes(
  :hosted_by => "dotsrc.org",
  :location => "Aalborg, Denmark",
  :networking => {
    :nameservers => [
      "130.226.1.2",
      "130.226.255.53",
      "2001:878:0:100::2"
    ],
    :roles => {
      :external => {
        :zone => "ds"
      }
    }
  }
)

override_attributes(
  :ntp => {
    :servers => ["0.dk.pool.ntp.org", "1.dk.pool.ntp.org", "europe.pool.ntp.org"]
  }
)

run_list(
  "role[dk]"
)
