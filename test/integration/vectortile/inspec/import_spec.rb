describe file("/usr/local/bin/import-planet") do
  it { should be_executable.by_user("tileupdate") }
end
