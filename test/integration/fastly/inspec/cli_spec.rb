describe package("fastly") do
  it { should be_installed }
end

describe command("fastly version") do
  its(:exit_status) { should eq 0 }
end
