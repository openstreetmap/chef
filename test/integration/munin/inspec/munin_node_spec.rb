describe package("munin-node") do
  it { should_not be_installed }
end

describe service("munin-node") do
  it { should_not be_enabled }
  it { should_not be_running }
end

describe port(4949) do
  it { should_not be_listening }
end
