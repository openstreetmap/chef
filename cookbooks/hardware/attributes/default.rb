default[:hardware][:modules] = %w[lp]
default[:hardware][:blacklisted_modules] = %w[]
default[:hardware][:grub][:cmdline] = %w[nomodeset]
default[:hardware][:sensors] = {}
default[:hardware][:hwmon] = {}
default[:hardware][:ipmi][:excluded_sensors] = []
default[:hardware][:ipmi][:custom_args] = []

if node[:dmi] && node[:dmi][:system]
  case node[:dmi][:system][:manufacturer]
  when "HP"
    case node[:dmi][:system][:product_name]
    when "ProLiant DL360 G6", "ProLiant DL360 G7", "ProLiant SE326M1R2"
      default[:hardware][:sensors][:"power_meter-*"][:power][:power1] = { :ignore => true }
    end

    case node[:dmi][:system][:product_name]
    when "ProLiant DL360 G6", "ProLiant DL360 G7", "ProLiant SE326M1R2", "ProLiant DL360e Gen8", "ProLiant DL360p Gen8"
      default[:hardware][:ipmi][:custom_args] |= ["--workaround-flags=discretereading"]
    end
  end
end

if Chef::Util.compare_versions(node[:kernel][:release], [3, 3]).negative?
  default[:hardware][:modules] |= ["microcode"]

  if node[:cpu][:"0"][:vendor_id] == "GenuineIntel"
    default[:hardware][:modules] |= ["coretemp"]
  end
end

if node[:kernel][:modules].include?("ipmi_si")
  default[:hardware][:modules] |= ["ipmi_devintf"]

  if node[:kernel][:modules].include?("acpi_power_meter")
    default[:hardware][:modules] |= ["acpi_ipmi"]
  end
end

if File.exist?("/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor") &&
   File.read("/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor").chomp == "ondemand"
  default[:sysfs][:cpufreq_ondemand][:comment] = "Tune the ondemand CPU frequency governor"
  default[:sysfs][:cpufreq_ondemand][:parameters][:"devices/system/cpu/cpufreq/ondemand/up_threshold"] = "25"
  default[:sysfs][:cpufreq_ondemand][:parameters][:"devices/system/cpu/cpufreq/ondemand/sampling_down_factor"] = "100"
  default[:sysfs][:cpufreq_ondemand][:parameters][:"devices/system/cpu/cpufreq/ondemand/ignore_nice_load"] = "1"
end

energy_perf_bias = Dir.glob("/sys/devices/system/cpu/cpu*/power/energy_perf_bias")

unless energy_perf_bias.empty?
  default[:sysfs][:cpu_power_energy_perf_bias][:comment] = "Set CPU Energy-Performance Bias Preference to balance-performance"

  energy_perf_bias.sort.each do |path|
    default[:sysfs][:cpu_power_energy_perf_bias][:parameters][path.sub(%r{^/sys/}, "")] = "4"
  end
end
