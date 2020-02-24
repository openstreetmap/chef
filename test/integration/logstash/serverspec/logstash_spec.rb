require "serverspec"

# Required by serverspec
set :backend, :exec

describe package("logstash") do
  it { should be_installed }
end

describe service("logstash") do
  it { should be_enabled }
  it { should be_running }
end

# describe port(5044) do
#  it { should be_listening.with("tcp") }
# end
