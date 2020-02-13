require "serverspec"

# Required by serverspec
set :backend, :exec

describe package("clamav-daemon") do
  it { should be_installed }
end

describe service("clamav-daemon") do
  it { should be_enabled }
  it { should be_running }
end

describe package("clamav-freshclam") do
  it { should be_installed }
end

describe service("clamav-freshclam") do
  it { should be_enabled }
  it { should be_running }
end
