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
  it { should be_listening }
  its("protocols") { should include "tcp" }
  # https://github.com/inspec/inspec/issues/3209
  # its("protocols") { should include "tcp6" }
end
