require "serverspec"

# Required by serverspec
set :backend, :exec

describe package("apache2") do
  it { should be_installed }
end

describe service("apache2") do
  it { should be_enabled }
  it { should be_running }
end

describe port(80) do
  it { should be_listening.with("tcp") }
end

describe port(443) do
  it { should be_listening.with("tcp") }
end
