require "serverspec"

# Required by serverspec
set :backend, :exec

describe service("backup-db.timer") do
  it { should be_enabled }
  it { should be_running }
end
