require "serverspec"

# Required by serverspec
set :backend, :exec

describe package("openssh-client") do
  it { should be_installed }
end

describe package("openssh-server") do
  it { should be_installed }
end

describe service("ssh") do
  it { should be_enabled }
  it { should be_running }
end

describe port(22) do
  it { should be_listening.with("tcp") }
end
