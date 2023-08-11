describe package("snmpd") do
  it { should be_installed }
end

describe service("snmpd") do
  it { should be_enabled }
  it { should be_running }
end

describe port(161) do
  it { should be_listening }
  its("protocols") { should cmp %w[udp] }
end
