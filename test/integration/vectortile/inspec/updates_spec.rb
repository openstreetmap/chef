describe file("/usr/local/bin/ocean-update") do
  it { should be_executable.by_user("tileupdate") }
end

describe service("ocean-update") do
  it { should be_installed }
end

describe file("/usr/local/bin/vector-update") do
  it { should be_executable.by_user("tileupdate") }
end

describe file("/usr/local/bin/tiles-rerender") do
  it { should be_executable.by_user("tileupdate") }
end

describe service("replicate") do
  it { should be_installed }
end
