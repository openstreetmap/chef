describe pip("tilekiln", "/opt/tilekiln/bin/pip") do
  it { should be_installed }
  its("version") { should cmp >= "0.5.0" }
end

describe service("tilekiln") do
  it { should be_enabled }
  it { should be_running }
end

describe port(8000) do
  it { should be_listening }
  its("protocols") { should cmp %w[tcp] }
end

describe http("http://localhost:8000") do
  its("status") { should cmp 404 }
end

describe http("https://localhost/shortbread_v1/tilejson.json", :ssl_verify => false) do
  its("status") { should cmp 200 }
end

# There are no tiles so everything should return a 404
describe http("https://localhost/shortbread_v1/0/0/0.mvt", :ssl_verify => false) do
  its("status") { should cmp 404 }
end
describe http("https://localhost/shortbread_v1/16/0/0.mvt", :ssl_verify => false) do
  its("status") { should cmp 404 }
end
