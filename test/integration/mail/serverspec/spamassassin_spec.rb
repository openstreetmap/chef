require "serverspec"

# Required by serverspec
set :backend, :exec

describe package("spamassassin") do
  it { should be_installed }
end

describe service("spamassassin") do
  it { should be_enabled }
  it { should be_running }
end

describe port(783) do
  it { should be_listening.with("tcp") }
end
