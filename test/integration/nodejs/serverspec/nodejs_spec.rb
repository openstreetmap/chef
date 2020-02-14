require "serverspec"

# Required by serverspec
set :backend, :exec

describe package("nodejs") do
  it { should be_installed }
end

describe package("npm") do
  it { should be_installed }
end
