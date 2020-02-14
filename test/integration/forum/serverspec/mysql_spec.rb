require "serverspec"

# Required by serverspec
set :backend, :exec

describe package("mysql-server") do
  it { should be_installed }
end

describe service("mysql") do
  it { should be_enabled }
  it { should be_running }
end

describe port(3306) do
  it { should be_listening.with("tcp") }
end
