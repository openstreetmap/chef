describe file("/usr/local/bin/tilekiln-storage-init") do
  it { should be_executable.by_user("tileupdate") }
end
