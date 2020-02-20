require "serverspec"

# Required by serverspec
set :backend, :exec

describe package("vsftpd") do
  it { should be_installed }
end

describe service("vsftpd") do
  it { should be_enabled }
  it { should be_running }
end

describe port(21) do
  it { should be_listening.with("tcp6") }
end
