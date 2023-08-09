describe command("/opt/awscli/v2/current/bin/aws --version") do
  its("exit_status") { should eq 0 }
end
