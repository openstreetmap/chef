describe package("nginx") do
  it { should be_installed }
end

describe service("nginx") do
  it { should be_enabled }
  it { should be_running }
end

describe port(80) do
  it { should be_listening }
  its("protocols") { should cmp %w[tcp tcp6] }
end

describe port(443) do
  it { should be_listening }
  its("protocols") { should cmp %w[tcp tcp6] }
end

describe http("http://localhost") do
  its("status") { should cmp 301 }
end

describe http("https://localhost", :ssl_verify => false) do
  its("status") { should cmp 200 }
end

describe http("https://localhost/styles/shortbread/colorful.json", :ssl_verify => false) do
  its("status") { should cmp 200 }
  its("headers") { should_not include "Access-Control-Allow-Origin" }
  its("headers.vary") { should cmp "Origin" }
end

describe http("https://localhost/styles/shortbread/colorful.json", :headers => { "Origin" => "https://www.openstreetmap.org" }, :ssl_verify => false) do
  its("status") { should cmp 200 }
  its("headers.Access-Control-Allow-Origin") { should cmp "https://www.openstreetmap.org" }
  its("headers.vary") { should cmp "Origin" }
end

describe json(:content => http("https://localhost/styles/shortbread/colorful.json", :ssl_verify => false).body) do
  its(%w[sources versatiles-shortbread tiles]) do
    should eq(["https://vector.openstreetmap.org/shortbread_v1/{z}/{x}/{y}.mvt"])
  end
  its(["sprite", 0, "url"]) { should match %r{https://vector.openstreetmap.org/} }
  its(["glyphs"]) { should match %r{https://vector.openstreetmap.org/} }
end
