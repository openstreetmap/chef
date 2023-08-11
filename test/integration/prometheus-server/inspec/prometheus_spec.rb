describe package("prometheus") do
  it { should be_installed }
end

describe service("prometheus") do
  it { should be_enabled }
  it { should be_running }
end

describe port(9090) do
  it { should be_listening }
  its("protocols") { should cmp "tcp" }
end
