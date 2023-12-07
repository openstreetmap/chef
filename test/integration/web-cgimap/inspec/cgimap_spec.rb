describe service("cgimap") do
  it { should be_enabled }
  it { should be_running }
end

describe file("/run/cgimap/socket") do
  it { should be_socket }
end
