require "serverspec"

# Required by serverspec
set :backend, :exec

describe package("sysfsutils") do
  it { should be_installed }
end

describe service("sysfsutils") do
  it { should be_enabled }
  it { should be_running }
end
