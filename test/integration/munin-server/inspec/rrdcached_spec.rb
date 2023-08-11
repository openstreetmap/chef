describe package("rrdcached") do
  it { should be_installed }
end

describe service("rrdcached") do
  it { should be_enabled }
  it { should be_running }
end
