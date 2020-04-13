name "aws"
description "Role applied to all servers on AWS"

default_attributes(
  :hosted_by => "AWS",
  :location => "Ireland",
  :networking => {
    :nameservers => ["172.31.0.2"],
    :roles => {
      :internal => {
        :inet => {
          :prefix => "20",
          :gateway => "172.31.0.1"
        }
      },
      :external => {
        :inet => {
          :prefix => "32"
        }
      }
    }
  }
)

override_attributes(
  :ntp => {
    :servers => ["0.ie.pool.ntp.org", "1.ie.pool.ntp.org", "europe.pool.ntp.org"]
  }
)

run_list(
  "role[ie]"
)
