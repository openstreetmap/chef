if node[:dmi] and node[:dmi][:system]
  case dmi.system.manufacturer
  when "HP"
    if node[:lsb][:release].to_f <= 11.10
      default[:apt][:sources] |= [ "proliant-support-pack" ]
    else
      default[:apt][:sources] |= [ "management-component-pack" ]
    end
  end
end

if node[:kernel] and node[:kernel][:modules]
  if node[:kernel][:modules].include?("mpt2sas")
    default[:apt][:sources] |= [ "hwraid" ]
  end
end
