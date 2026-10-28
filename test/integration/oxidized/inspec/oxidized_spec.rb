describe directory("/etc/oxidized/model") do
  it { should exist }
  its("owner") { should eq "root" }
  its("group") { should eq "root" }
  its("mode") { should cmp "0755" }
end

describe file("/etc/oxidized/model/apcats.rb") do
  it { should be_file }
  its("owner") { should eq "root" }
  its("group") { should eq "root" }
  its("mode") { should cmp "0644" }
end

describe service("oxidized") do
  it { should be_enabled }
  it { should be_running }
end
