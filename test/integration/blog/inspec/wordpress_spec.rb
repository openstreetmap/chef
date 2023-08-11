describe command("/opt/wp-cli/wp --allow-root --path=/srv/blog.openstreetmap.org/wp/ core is-installed") do
  its("exit_status") { should eq 0 }
end

describe command("/opt/wp-cli/wp --allow-root --path=/srv/blog.openstreetmap.org/wp/ plugin is-active wp-fail2ban") do
  its("exit_status") { should eq 0 }
end
