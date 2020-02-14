require "serverspec"

# Required by serverspec
set :backend, :exec

describe package("squid") do
  it { should be_installed }
end

describe service("squid") do
  it { should be_enabled }
  it { should be_running }
end

describe port(3128) do
  it { should be_listening.with("tcp") }
end

describe port(8080) do
  it { should be_listening.with("tcp") }
end
