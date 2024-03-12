name "hp-dl360-g6"
description "Role applied to all HP DL360 G6 machines"

default_attributes(
  :hardware => {
    :blacklisted_modules => %w[acpi_power_meter]
  }
)
