describe package("nftables") do
  it { should be_installed }
end

describe service("nftables") do
  it { should be_enabled }
  it { should be_running }
end

describe file("/etc/nftables.conf") do
  it { should be_file }
  its(:content) { should match(/echo-request.*accept/) }
  its(:content) { should match(/http.*accept/) }
  its(:content) { should match(/https.*accept/) }
end
