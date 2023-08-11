mysql_variant = if os.name == "ubuntu"
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
  it { should be_listening }
  its("protocols") { should cmp "tcp" }
end
