describe package("dnscontrol") do
  it { should be_installed }
end

describe command("dnscontrol version") do
  its(:exit_status) { should eq 0 }
end
