require "serverspec"

# Required by serverspec
set :backend, :exec

describe package("git") do
  it { should be_installed }
end
