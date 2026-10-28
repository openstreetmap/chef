require "oxidized/model/apcaos"

class ApcAts < ApcAos
  inputs [:ssh, :scp]

  cmd "upsabout", :clear => true, :if => -> { false }
  cmd "detstatus -ss", :clear => true, :if => -> { false }
end
