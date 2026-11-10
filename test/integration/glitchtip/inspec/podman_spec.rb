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

describe command("podman run --rm --pull=never --entrypoint=id docker.io/glitchtip/glitchtip:6") do
  its("exit_status") { should eq 0 }
  its("stdout") { should match(/\Auid=5000\b/) }
  its("stdout") { should match(/\bgid=5000\b/) }
end

mapping = yaml("/var/lib/podman/mappings.yml").params["glitchtip.openstreetmap.org"]

describe file("/var/lib/podman/mappings.yml") do
  its("mode") { should cmp "0600" }
end

describe file("/etc/containers/systemd/glitchtip.openstreetmap.org.container") do
  its("content") { should match(/^UIDMap=0:#{mapping}:65536$/) }
  its("content") { should match(/^GIDMap=0:#{mapping}:65536$/) }
  its("content") { should_not match(/^UserNS=/) }
  its("content") { should match(%r{^Volume=/srv/glitchtip.openstreetmap.org/uploads:/code/uploads$}) }
  its("content") { should match(%r{^Volume=/srv/glitchtip.openstreetmap.org/cold:/cold$}) }
end

%w[uploads cold].each do |name|
  describe directory("/srv/glitchtip.openstreetmap.org/#{name}") do
    its("uid") { should eq mapping + 5000 }
    its("gid") { should eq mapping + 5000 }
    its("mode") { should cmp "0700" }
  end

  %w[/srv /srv/glitchtip.openstreetmap.org].each do |path|
    describe directory(path) do
      its("uid") { should eq 0 }
      its("gid") { should eq 0 }
      its("mode") { should cmp "0755" }
    end
  end
end
