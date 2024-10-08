describe package("nginx") do
  it { should be_installed }
end

describe service("nginx") do
  it { should be_enabled }
  it { should be_running }
end

describe port(80) do
  it { should be_listening }
  its("protocols") { should cmp %w[tcp tcp6] }
end

describe port(443) do
  it { should be_listening }
  its("protocols") { should cmp %w[tcp tcp6] }
end

describe http("http://localhost") do
  its("status") { should cmp 301 }
end

describe http("https://localhost", :ssl_verify => false) do
  its("status") { should cmp 200 }
end
