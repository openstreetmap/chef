name "shenron"
description "Master role applied to shenron"

default_attributes(
  :apache => {
    :mpm => "event",
    :event => {
      :min_spare_threads => 50,
      :max_spare_threads => 150
    }
  },
  :hardware => {
    :hwmon => {
      "platform_it87_552" => {
        :ignore => %w[in6]
      }
    },
    :mcelog => {
      :enabled => false
    },
    :modules => [
      "it87"
    ]
  }
)

override_attributes(
  :networking => {
    :dnssec => "false",
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet,
        :address => "212.110.172.32",
        :prefix => "26",
        :gateway => "212.110.172.1"
      },
      :external_ipv6 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet6,
        :address => "2001:41c9:1:400::32",
        :prefix => "64",
        :gateway => "fe80::1"
      }
    },
    # Do not use Cloudflare Public DNS as it does not support ECS as required by https://www.spamhaus.org/organization/dnsblusage/
    # https://www.spamhaus.org/news/article/816/service-update-spamhaus-dnsbl-users-who-query-via-cloudflare-dns-need-to-make-changes-to-email-set-up
    :nameservers => ["8.8.8.8", "8.8.4.4", "2001:4860:4860::8888", "2001:4860:4860::8844"],
    :private_address => "10.0.16.100"
  }
)

run_list(
  "role[bytemark]",
  "role[mail]",
  "role[lists]",
  "role[osqa]",
  "recipe[blogs]"
)
