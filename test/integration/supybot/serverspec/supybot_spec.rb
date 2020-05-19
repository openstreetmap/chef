require "serverspec"

# Required by serverspec
set :backend, :exec

describe package("limnoria") do
  it { should be_installed }
end

describe service("supybot") do
  it { should be_enabled }
  it { should be_running }
end
