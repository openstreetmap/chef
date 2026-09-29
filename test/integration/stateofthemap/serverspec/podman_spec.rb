require "serverspec"

# Required by serverspec
set :backend, :exec

%w[2007 2008 2009 2010 2011 2012 2013 2016 2017 2018 2019 2020 2021 2022 2024 2025 2026].each do |year|
  describe command("podman image inspect ghcr.io/openstreetmap/stateofthemap-#{year}:latest") do
    its(:exit_status) { should eq 0 }
  end

  describe command("podman container inspect #{year}.stateofthemap.org") do
    its(:exit_status) { should eq 0 }
  end
end
