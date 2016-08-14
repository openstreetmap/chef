require "serverspec"

# Required by serverspec
set :backend, :exec

describe package("shorewall") do
  it { should be_installed }
end

describe service("shorewall") do
  it { should be_enabled }
  it { should be_running }
end

describe file("/etc/shorewall/rules") do
  it { should be_file }
  its(:content) { should match(/ACCEPT.*echo-request/) }
  its(:content) { should match(/ACCEPT.*http/) }
  its(:content) { should match(/ACCEPT.*https/) }
end
