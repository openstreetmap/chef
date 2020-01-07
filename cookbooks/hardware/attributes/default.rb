default[:hardware][:modules] = %w[lp]
default[:hardware][:grub][:cmdline] = %w[nomodeset]
default[:hardware][:sensors] = {}

if node[:dmi] && node[:dmi][:system]
  case node[:dmi][:system][:manufacturer]
  when "HP"
    default[:apt][:sources] |= ["management-component-pack"]

    case node[:dmi][:system][:product_name]
    when "ProLiant DL360 G6", "ProLiant DL360 G7", "ProLiant SE326M1R2"
      default[:hardware][:sensors][:"power_meter-*"][:power][:power1] = { :ignore => true }
    end
  end
end

if Chef::Util.compare_versions(node[:kernel][:release], [3, 3]).negative?
  default[:hardware][:modules] |= ["microcode"]

  if node[:cpu][:"0"][:vendor_id] == "GenuineIntel"
    default[:hardware][:modules] |= ["coretemp"]
  end
end

if node[:kernel] && node[:kernel][:modules]
  raidmods = node[:kernel][:modules].keys & %w[cciss hpsa mptsas mpt2sas mpt3sas megaraid_mm megaraid_sas aacraid]

  default[:apt][:sources] |= ["hwraid"] unless raidmods.empty?
end

if node[:kernel][:modules].include?("ipmi_si")
  default[:hardware][:modules] |= ["ipmi_devintf"]
end

if File.exist?("/proc/xen")
  default[:hardware][:watchdog] = "xen_wdt"
elsif node[:kernel][:modules].include?("i6300esb")
  default[:hardware][:watchdog] = "none"
end

if File.exist?("/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor") &&
   File.read("/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor").chomp == "ondemand"
  default[:sysfs][:cpufreq_ondemand][:comment] = "Tune the ondemand CPU frequency governor"
  default[:sysfs][:cpufreq_ondemand][:parameters][:"devices/system/cpu/cpufreq/ondemand/up_threshold"] = "25"
  default[:sysfs][:cpufreq_ondemand][:parameters][:"devices/system/cpu/cpufreq/ondemand/sampling_down_factor"] = "100"
end
