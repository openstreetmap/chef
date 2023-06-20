require "serverspec"

# Required by serverspec
set :backend, :exec

service_name = if os[:family] == "debian"
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
  it { should be_listening.with("tcp") }
end
