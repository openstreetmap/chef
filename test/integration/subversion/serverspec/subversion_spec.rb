require "serverspec"

# Required by serverspec
set :backend, :exec

describe package("subversion") do
  it { should be_installed }
end
