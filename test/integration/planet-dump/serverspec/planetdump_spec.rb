require "serverspec"

# Required by serverspec
set :backend, :exec

describe file("/opt/planet-dump-ng/planet-dump-ng") do
  it { should be_file }
  it { should be_executable }
end

describe file("/usr/local/bin/planetdump") do
  it { should be_file }
  it { should be_executable }
end

describe file("/usr/local/bin/planet-mirror-redirect-update") do
  it { should be_file }
  it { should be_executable }
end

describe file("/etc/cron.d/planet-dump-mirror") do
  it { should be_file }
end
