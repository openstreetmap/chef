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

describe command("podman image inspect ghcr.io/dani-garcia/vaultwarden:latest") do
  its("exit_status") { should eq 0 }
end

describe command("podman run --rm --pull=never --entrypoint=id ghcr.io/dani-garcia/vaultwarden:latest") do
  its("exit_status") { should eq 0 }
  its("stdout") { should match(/\Auid=0\b/) }
  its("stdout") { should match(/\bgid=0\b/) }
end

mapping = yaml("/var/lib/podman/mappings.yml").params["vault.osmfoundation.org"]

describe file("/var/lib/podman/mappings.yml") do
  its("mode") { should cmp "0600" }
end

describe file("/etc/containers/systemd/vault.osmfoundation.org.container") do
  its("content") { should match(/^UIDMap=0:#{mapping}:65536$/) }
  its("content") { should match(/^GIDMap=0:#{mapping}:65536$/) }
  its("content") { should_not match(/^UserNS=/) }
  its("content") { should match(%r{^Volume=/srv/vault.osmfoundation.org/data:/data$}) }
end

describe directory("/srv/vault.osmfoundation.org/data") do
  its("uid") { should eq mapping }
  its("gid") { should eq mapping }
  its("mode") { should cmp "0700" }
end

%w[/srv /srv/vault.osmfoundation.org].each do |path|
  describe directory(path) do
    its("uid") { should eq 0 }
    its("gid") { should eq 0 }
    its("mode") { should cmp "0755" }
  end
end
