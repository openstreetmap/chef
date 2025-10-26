describe port(80) do
  it { should be_listening }
  its("protocols") { should cmp %w[tcp tcp6] }
end

describe port(443) do
  it { should be_listening }
  its("protocols") { should cmp %w[tcp tcp6] }
end

describe http("http://localhost/.well-known/acme-challenge/abc",
              :headers => { "Host" => "community.openstreetmap.org" },
              :allow_redirects => false) do
  its("status") { should cmp 301 }
  its("headers.Location") { should cmp %r{^http://acme\.openstreetmap\.org/} }
end
