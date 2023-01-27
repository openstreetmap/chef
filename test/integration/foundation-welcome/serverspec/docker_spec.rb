require "serverspec"

# Required by serverspec
set :backend, :exec

describe package("docker-ce") do
  it { should be_installed }
end

describe service("docker") do
  it { should be_enabled }
  it { should be_running }
end

describe docker_container("welcome-mat") do
  it { should exist }
  it { should be_running }
end
