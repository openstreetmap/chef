require "serverspec"

# Required by serverspec
set :backend, :exec

describe package("incron") do
  it { should be_installed }
end

describe service("incron") do
  it { should be_enabled }
  it { should be_running }
end
