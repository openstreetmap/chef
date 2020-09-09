require "serverspec"

# Required by serverspec
set :backend, :exec

describe service("api-statistics") do
  it { should be_enabled }
  it { should be_running }
end

describe service("rails-jobs@mailers") do
  it { should be_enabled }
  it { should be_running }
end

describe service("rails-jobs@storage") do
  it { should be_enabled }
  it { should be_running }
end
