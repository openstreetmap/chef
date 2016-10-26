Vagrant.configure(2) do |config|
  config.vm.provision "shell", :inline => <<-SHELL
    apt-get update -y
  SHELL
end
