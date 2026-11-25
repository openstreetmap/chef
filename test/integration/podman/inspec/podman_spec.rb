describe package("podman") do
  it { should be_installed }
end

describe directory("/var/lib/podman") do
  it { should be_owned_by "root" }
  its("mode") { should cmp "0700" }
end

["/etc/subuid", "/etc/subgid"].each do |path|
  describe file(path) do
    its("content") { should match(/^containers:2147483647:1073741825$/) }
    its("content") { should_not match(/^containers:2147483647:2147483648$/) }
  end
end

describe service("podman-auto-update.timer") do
  it { should be_enabled }
  it { should be_running }
end

describe service("podman-system-prune.timer") do
  it { should be_enabled }
  it { should be_running }
end

# Note - In limited testing podman does not run reliably inside a dokken container.
# Be careful if you add a podman run test here.
