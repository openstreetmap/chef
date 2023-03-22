require "serverspec"

# Required by serverspec
set :backend, :exec

mysql_variant = if os[:family] == "ubuntu"
                  "mysql"
                else
                  "mariadb"
                end

describe package("#{mysql_variant}-server") do
  it { should be_installed }
end

describe service("#{mysql_variant}") do
  it { should be_enabled }
  it { should be_running }
end

describe port(3306) do
  it { should be_listening.with("tcp") }
end
