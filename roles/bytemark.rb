name "bytemark"
description "Role applied to all servers at Bytemark"

default_attributes(
  :hosted_by => "Bytemark",
  :location => "York, England",
  :networking => {
    :nameservers => ["8.8.8.8", "8.8.4.4", "2001:4860:4860::8888", "2001:4860:4860::8844"],
    :roles => {
      :external => {
        :zone => "bm"
      }
    }
  }
)

override_attributes(
  :ntp => {
    :servers => ["0.uk.pool.ntp.org", "1.uk.pool.ntp.org", "europe.pool.ntp.org"]
  }
)

run_list(
  "role[gb]"
)
