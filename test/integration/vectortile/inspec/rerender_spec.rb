describe file("/usr/local/bin/render-lowzoom") do
  it { should be_executable.by_user("tileupdate") }
end

describe service("render-lowzoom") do
  it { should be_installed }
end
