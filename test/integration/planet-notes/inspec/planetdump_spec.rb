describe file("/usr/local/bin/planet-notes-dump") do
  it { should be_file }
  it { should be_executable }
end

describe service("planet-notes-dump.timer") do
  it { should be_enabled }
  it { should be_running }
end
