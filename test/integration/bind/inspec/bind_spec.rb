describe package("bind9") do
  it { should be_installed }
end

describe service("bind9") do
  it { should be_enabled }
  it { should be_running }
end

describe port(53) do
  it { should be_listening }
  its("protocols") { should cmp %w[udp udp6 tcp tcp6] }
end
