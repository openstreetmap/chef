describe file("/opt/planet-dump-ng/planet-dump-ng") do
  it { should be_file }
  it { should be_executable }
end

describe file("/usr/local/bin/planetdump") do
  it { should be_file }
  it { should be_executable }
end
