describe package("osm2pgsql") do
  it { should be_installed }
  its("version") { should cmp >= "1.11.0" }
end
