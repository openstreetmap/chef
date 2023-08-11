describe package("docker-ce") do
  it { should be_installed }
end

describe service("docker") do
  it { should be_enabled }
  it { should be_running }
end

describe docker_image("local_discourse/data:latest") do
  it { should exist }
end

describe docker_image("local_discourse/mail-receiver:latest") do
  it { should exist }
end

describe docker_image("local_discourse/web_only:latest") do
  it { should exist }
end
