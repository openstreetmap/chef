require "serverspec"

# Required by serverspec
set :backend, :exec

describe package("prometheus-alertmanager") do
  it { should be_installed }
end

describe service("prometheus-alertmanager") do
  it { should be_enabled }
  it { should be_running }
end

describe port(9093) do
  it { should be_listening.with("tcp6") }
end
