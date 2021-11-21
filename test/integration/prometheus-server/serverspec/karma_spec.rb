require "serverspec"

# Required by serverspec
set :backend, :exec

describe service("prometheus-karma") do
  it { should be_enabled }
  it { should be_running }
end

describe port(8081) do
  it { should be_listening.with("tcp6") }
end
