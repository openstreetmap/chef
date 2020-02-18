require "serverspec"

# Required by serverspec
set :backend, :exec

describe package("mailman") do
  it { should be_installed }
end

describe service("mailman") do
  it { should be_enabled }
  it { should be_running }
end
