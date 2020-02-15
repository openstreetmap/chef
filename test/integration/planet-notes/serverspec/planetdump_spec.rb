require "serverspec"

# Required by serverspec
set :backend, :exec

describe file("/usr/local/bin/planet-notes-dump") do
  it { should be_file }
  it { should be_executable }
end

describe file("/etc/cron.d/planet-notes-dump") do
  it { should be_file }
end
