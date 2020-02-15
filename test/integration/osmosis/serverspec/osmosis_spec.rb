require "serverspec"

# Required by serverspec
set :backend, :exec

describe file("/usr/local/bin/osmosis") do
  it { should be_symlink }
end
