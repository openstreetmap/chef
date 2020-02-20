require "serverspec"

# Required by serverspec
set :backend, :exec

describe package("supybot") do
  it { should be_installed }
end

describe service("supybot") do
  it { should be_enabled }
  it { should be_running }
end
