default[:hardware][:sensors] = {}

if node[:dmi] and node[:dmi][:system]
  case dmi.system.manufacturer
  when "HP"
    default[:apt][:sources] |= [ "management-component-pack" ]

    case dmi.system.product_name
      when "ProLiant DL360 G6", "ProLiant DL360 G7"
        default[:hardware][:sensors]["power_meter-*"][:power]["power1"] = { :ignore => true }
    end
  end
end

if node[:kernel] and node[:kernel][:modules]
  raidmods = node[:kernel][:modules].keys & ["cciss", "hpsa", "mptsas", "mpt2sas", "megaraid_mm", "megaraid_sas", "aacraid"]

  unless raidmods.empty?
    default[:apt][:sources] |= [ "hwraid" ]
  end
end
