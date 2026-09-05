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

describe command("podman image inspect glitchtip/glitchtip:6") do
  its("exit_status") { should eq 0 }
end
