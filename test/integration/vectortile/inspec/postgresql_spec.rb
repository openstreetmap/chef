describe package("postgresql-16") do
  it { should be_installed }
end

describe service("postgresql@16-main") do
  it { should be_enabled }
  it { should be_running }
end

describe port(5432) do
  it { should be_listening }
  its("protocols") { should cmp %w[tcp tcp6] }
end
