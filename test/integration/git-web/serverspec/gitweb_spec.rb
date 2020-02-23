require "serverspec"

# Required by serverspec
set :backend, :exec

describe package("gitweb") do
  it { should be_installed }
end
