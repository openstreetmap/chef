require "serverspec"

# Required by serverspec
set :backend, :exec

describe package("nodejs") do
  it { should be_installed }
end

describe package("yarn") do
  it { should be_installed }
end
