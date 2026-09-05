describe package("valkey-server") do
  it { should be_installed }
end

describe service("valkey") do
  it { should be_enabled }
  it { should be_running }
end

describe port(6379) do
  it { should be_listening }
  its("protocols") { should cmp %w[tcp tcp6] }
end
