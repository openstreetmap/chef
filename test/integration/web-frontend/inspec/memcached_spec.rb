describe package("memcached") do
  it { should be_installed }
end

describe service("memcached") do
  it { should be_enabled }
  it { should be_running }
end

describe port(11211) do
  it { should be_listening }
  its("protocols") { should cmp "tcp" }
end
