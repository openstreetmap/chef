require "serverspec"

# Required by serverspec
set :backend, :exec

describe "munin-node daemon" do
  it "has a running service of munin-node" do
    expect(service("munin-node")).to be_running
  end
end
