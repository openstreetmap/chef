Vagrant.configure(2) do |config|
  config.vm.provision "shell", :inline => <<-SHELL
    sed -i -e '/nameservers:/d' -e '/addresses:/d' /etc/netplan/01-netcfg.yaml
    netplan apply
    apt-get update -y
  SHELL
end
