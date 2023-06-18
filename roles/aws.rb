name "aws"
description "Role applied to all servers at AWS"

default_attributes(
  :hosted_by => "AWS"
)

override_attributes(
  :ntp => {
    :servers => ["169.254.169.123"]
  }
)
