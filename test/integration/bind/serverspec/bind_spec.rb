require "serverspec"

# Required by serverspec
set :backend, :exec

describe package("bind9") do
  it { should be_installed }
end

describe service("bind9") do
  it { should be_enabled }
  it { should be_running }
end
