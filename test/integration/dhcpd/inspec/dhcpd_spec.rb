describe package("isc-dhcp-server") do
  it { should be_installed }
end

describe service("isc-dhcp-server") do
  it { should be_enabled }
  it { should be_running }
end

describe port(67) do
  it { should be_listening }
  its("protocols") { should cmp "udp" }
end
