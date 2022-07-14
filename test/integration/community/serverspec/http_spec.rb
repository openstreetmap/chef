require "serverspec"

# Required by serverspec
set :backend, :exec

describe port(80) do
  it { should be_listening.with("tcp") }
end

describe port(443) do
  it { should be_listening.with("tcp") }
end
