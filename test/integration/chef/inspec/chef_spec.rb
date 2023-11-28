describe package("chef") do
  it { should be_installed }
end

describe systemd_service("chef-client") do
  it { should be_installed }
end

describe systemd_service("chef-client.timer") do
  it { should be_installed }
  it { should be_enabled }
end

describe command("chef-client --version") do
  its("exit_status") { should eq 0 }
  its("stdout") { should match /Chef Infra Client/ }
end
