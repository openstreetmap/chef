require "serverspec"

# Required by serverspec
set :backend, :exec

describe package("chrony") do
  it { should be_installed }
end

describe service("chronyd") do
  it { should be_enabled }
  it { should be_running }
end
