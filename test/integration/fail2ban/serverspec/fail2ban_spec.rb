require "serverspec"

# Required by serverspec
set :backend, :exec

describe package("fail2ban") do
  it { should be_installed }
end

describe service("fail2ban") do
  it { should be_enabled }
  it { should be_running }
end
