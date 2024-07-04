describe pip("tilekiln", "/opt/tilekiln/bin/pip") do
  it { should be_installed }
  its("version") { should cmp >= "0.5.0" }
end

describe service("tilekiln") do
  it { should be_enabled }
  it { should be_running }
end

describe port(8000) do
  it { should be_listening }
  its("protocols") { should cmp %w[tcp] }
end

describe http("http://localhost:8000") do
  its("status") { should cmp 404 }
end
