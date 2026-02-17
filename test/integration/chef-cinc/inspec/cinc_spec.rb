describe package("cinc") do
  it { should be_installed }
end

describe systemd_service("cinc-client") do
  it { should be_installed }
end

describe systemd_service("cinc-client.timer") do
  it { should be_installed }
  it { should be_enabled }
end

describe command("cinc-client --version") do
  its("exit_status") { should eq 0 }
  its("stdout") { should match /Cinc Client/ }
end
