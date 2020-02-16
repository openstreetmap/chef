require "serverspec"

# Required by serverspec
set :backend, :exec

describe package("postgresql-10") do
  it { should be_installed }
end

describe service("postgresql@10-main") do
  it { should be_enabled }
  it { should be_running }
end

describe port(5432) do
  it { should be_listening.with("tcp") }
end
