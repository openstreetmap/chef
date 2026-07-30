describe service("tilekiln-prometheus") do
  it { should be_enabled }
  it { should be_running }
end

describe port(10013) do
  it { should be_listening }
end
