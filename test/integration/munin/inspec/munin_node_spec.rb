describe package("munin-node") do
  it { should be_installed }
end

describe service("munin-node") do
  it { should be_enabled }
  it { should be_running }
end

describe port(4949) do
  it { should be_listening }
  its("protocols") { should cmp "tcp" }
end
