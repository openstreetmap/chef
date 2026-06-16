describe package("podman") do
  it { should be_installed }
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
