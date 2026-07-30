service_name = if os.name == "debian" || (os.name == "ubuntu" && os.release.to_f >= 24.04)
                 "spamd"
               else
                 "spamassassin"
               end

describe package("spamassassin") do
  it { should be_installed }
end

describe service(service_name) do
  it { should be_enabled }
  it { should be_running }
end

describe port(783) do
  it { should be_listening }
  its("protocols") { should cmp %w[tcp tcp6] }
end
