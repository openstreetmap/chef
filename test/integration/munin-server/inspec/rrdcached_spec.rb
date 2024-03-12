describe package("rrdcached") do
  it { should_not be_installed }
end

describe service("rrdcached") do
  it { should_not be_enabled }
  it { should_not be_running }
end
