require "serverspec"

# Required by serverspec
set :backend, :exec

describe package("elasticsearch") do
  it { should be_installed }
end

describe service("elasticsearch") do
  it { should be_enabled }
  it { should be_running }
end

# describe port(9200) do
#  it { should be_listening.with("tcp") }
# end
