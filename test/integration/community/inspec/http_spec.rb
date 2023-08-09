describe port(80) do
  it { should be_listening }
  its("protocols") { should cmp %w[tcp tcp6] }
end

describe port(443) do
  it { should be_listening }
  its("protocols") { should cmp %w[tcp tcp6] }
end
