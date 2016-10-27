require "serverspec"

# Required by serverspec
set :backend, :exec

describe package("munin") do
  it { should be_installed }
end
