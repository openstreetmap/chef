require "serverspec"

# Required by serverspec
set :backend, :exec

describe package("grafana-enterprise") do
  it { should be_installed }
end

describe service("grafana-server") do
  it { should be_enabled }
  it { should be_running }
end

describe port(3000) do
  it { should be_listening.with("tcp6") }
end
