if node[:dmi] and node[:dmi][:system]
  case dmi.system.manufacturer
  when "HP"
    default[:apt][:sources] |= [ "management-component-pack" ]
  end
end

if node[:kernel] and node[:kernel][:modules]
  raidmods = node[:kernel][:modules].keys & ["cciss", "hpsa", "mptsas", "mpt2sas", "megaraid_mm", "megaraid_sas", "aacraid"]

  unless raidmods.empty?
    default[:apt][:sources] |= [ "hwraid" ]
  end
end
