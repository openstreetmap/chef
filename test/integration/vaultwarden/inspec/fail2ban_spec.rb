describe package("fail2ban") do
  it { should be_installed }
end

describe service("fail2ban") do
  it { should be_enabled }
  it { should be_running }
end

describe file("/etc/fail2ban/jail.d/50-vaultwarden.conf") do
  it { should be_file }
  its("content") { should match(/^journalmatch = _SYSTEMD_UNIT=vault.osmfoundation.org.service$/) }
end

describe file("/etc/fail2ban/filter.d/vaultwarden.conf") do
  it { should be_file }
end
