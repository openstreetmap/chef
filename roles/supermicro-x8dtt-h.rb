name "supermicro-x8dtt-h"
description "Role applied to all Supermicro X8DTT-H machines"

default_attributes(
  :hardware => {
    :watchdog => "w83627hf_wdt"
  }
)
