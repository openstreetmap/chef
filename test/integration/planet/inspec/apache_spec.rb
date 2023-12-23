describe package("apache2") do
  it { should be_installed }
end

describe service("apache2") do
  it { should be_enabled }
  it { should be_running }
end

describe port(80) do
  it { should be_listening }
  its("protocols") { should cmp "tcp" }
end

describe port(443) do
  it { should be_listening }
  its("protocols") { should cmp "tcp" }
end

describe http("http://localhost") do
  its("status") { should cmp 200 }
end

# Minutely Replication Diffs

describe http("https://127.0.0.1/replication/minute/state.txt",
              :headers => { "Host" => "planet.openstreetmap.org" },
              :ssl_verify => false) do
  its("status") { should eq 302 }
  its("headers.Location") { should eq "https://osm-planet-eu-central-1.s3.dualstack.eu-central-1.amazonaws.com/planet/replication/minute/state.txt" }
end

describe http("https://127.0.0.1/replication/changesets/001/002/003.state.txt",
              :headers => { "Host" => "planet.openstreetmap.org" },
              :ssl_verify => false) do
  its("status") { should eq 302 }
  its("headers.Location") { should eq "https://osm-planet-eu-central-1.s3.dualstack.eu-central-1.amazonaws.com/changesets/replication/minute/001/002/003.state.txt" }
end

describe http("https://127.0.0.1/replication/minute/001/002/003.osc.gz",
              :headers => { "Host" => "planet.openstreetmap.org" },
              :ssl_verify => false) do
  its("status") { should eq 302 }
  its("headers.Location") { should eq "https://osm-planet-eu-central-1.s3.dualstack.eu-central-1.amazonaws.com/planet/replication/minute/001/002/003.osc.gz" }
end

# Hourly Replication Diffs

describe http("https://127.0.0.1/replication/hour/state.txt",
              :headers => { "Host" => "planet.openstreetmap.org" },
              :ssl_verify => false) do
  its("status") { should eq 302 }
  its("headers.Location") { should eq "https://osm-planet-eu-central-1.s3.dualstack.eu-central-1.amazonaws.com/planet/replication/hour/state.txt" }
end

describe http("https://127.0.0.1/replication/hour/001/002/003.state.txt",
              :headers => { "Host" => "planet.openstreetmap.org" },
              :ssl_verify => false) do
  its("status") { should eq 302 }
  its("headers.Location") { should eq "https://osm-planet-eu-central-1.s3.dualstack.eu-central-1.amazonaws.com/planet/replication/hour/001/002/003.state.txt" }
end

describe http("https://127.0.0.1/replication/minute/001/002/003.osc.gz",
              :headers => { "Host" => "planet.openstreetmap.org" },
              :ssl_verify => false) do
  its("status") { should eq 302 }
  its("headers.Location") { should eq "https://osm-planet-eu-central-1.s3.dualstack.eu-central-1.amazonaws.com/planet/replication/minute/001/002/003.osc.gz" }
end

# Daily Replication Diffs

describe http("https://127.0.0.1/replication/day/state.txt",
              :headers => { "Host" => "planet.openstreetmap.org" },
              :ssl_verify => false) do
  its("status") { should eq 302 }
  its("headers.Location") { should eq "https://osm-planet-eu-central-1.s3.dualstack.eu-central-1.amazonaws.com/planet/replication/day/state.txt" }
end

describe http("https://127.0.0.1/replication/day/001/002/003.state.txt",
              :headers => { "Host" => "planet.openstreetmap.org" },
              :ssl_verify => false) do
  its("status") { should eq 302 }
  its("headers.Location") { should eq "https://osm-planet-eu-central-1.s3.dualstack.eu-central-1.amazonaws.com/planet/replication/day/001/002/003.state.txt" }
end

describe http("https://127.0.0.1/replication/day/001/002/003.osc.gz",
              :headers => { "Host" => "planet.openstreetmap.org" },
              :ssl_verify => false) do
  its("status") { should eq 302 }
  its("headers.Location") { should eq "https://osm-planet-eu-central-1.s3.dualstack.eu-central-1.amazonaws.com/planet/replication/day/001/002/003.osc.gz" }
end

# Changeset Replication Diffs

describe http("https://127.0.0.1/replication/changesets/state.yaml",
              :headers => { "Host" => "planet.openstreetmap.org" },
              :ssl_verify => false) do
  its("status") { should eq 302 }
  its("headers.Location") { should eq "https://osm-planet-eu-central-1.s3.dualstack.eu-central-1.amazonaws.com/changesets/replication/minute/state.yaml" }
end

describe http("https://127.0.0.1/replication/changesets/001/002/003.state.txt",
              :headers => { "Host" => "planet.openstreetmap.org" },
              :ssl_verify => false) do
  its("status") { should eq 302 }
  its("headers.Location") { should eq "https://osm-planet-eu-central-1.s3.dualstack.eu-central-1.amazonaws.com/changesets/replication/minute/001/002/003.state.txt" }
end

describe http("https://127.0.0.1/replication/changesets/001/002/003.osm.gz",
              :headers => { "Host" => "planet.openstreetmap.org" },
              :ssl_verify => false) do
  its("status") { should eq 302 }
  its("headers.Location") { should eq "https://osm-planet-eu-central-1.s3.dualstack.eu-central-1.amazonaws.com/changesets/replication/minute/001/002/003.osm.gz" }
end

# Planet File

describe http("https://127.0.0.1/planet/2023/planet-231016.osm.bz2",
              :headers => { "Host" => "planet.openstreetmap.org" },
              :ssl_verify => false) do
  its("status") { should eq 302 }
  its("headers.Location") { should eq "https://osm-planet-eu-central-1.s3.dualstack.eu-central-1.amazonaws.com/planet/osm/2023/planet-231016.osm.bz2" }
end

# Planet File MD5

describe http("https://127.0.0.1/planet/2023/planet-231016.osm.bz2.md5",
              :headers => { "Host" => "planet.openstreetmap.org" },
              :ssl_verify => false) do
  its("status") { should eq 302 }
  its("headers.Location") { should eq "https://osm-planet-eu-central-1.s3.dualstack.eu-central-1.amazonaws.com/planet/osm/2023/planet-231016.osm.bz2.md5" }
end

# Full History Planet File

describe http("https://127.0.0.1/planet/full-history/2023/history-231016.osm.bz2",
              :headers => { "Host" => "planet.openstreetmap.org" },
              :ssl_verify => false) do
  its("status") { should eq 302 }
  its("headers.Location") { should eq "https://osm-planet-eu-central-1.s3.dualstack.eu-central-1.amazonaws.com/planet-full-history/osm/2023/history-231016.osm.bz2" }
end

# Full History Planet File MD5

describe http("https://127.0.0.1/planet/full-history/2023/history-231016.osm.bz2.md5",
              :headers => { "Host" => "planet.openstreetmap.org" },
              :ssl_verify => false) do
  its("status") { should eq 302 }
  its("headers.Location") { should eq "https://osm-planet-eu-central-1.s3.dualstack.eu-central-1.amazonaws.com/planet-full-history/osm/2023/history-231016.osm.bz2.md5" }
end

# PBF planet file

describe http("https://127.0.0.1/pbf/planet-231016.osm.pbf",
              :headers => { "Host" => "planet.openstreetmap.org" },
              :ssl_verify => false) do
  its("status") { should eq 302 }
  its("headers.Location") { should eq "https://osm-planet-eu-central-1.s3.dualstack.eu-central-1.amazonaws.com/planet/pbf/2023/planet-231016.osm.pbf" }
end

# PBF full history planet file

describe http("https://127.0.0.1/pbf/full-history/history-231016.osm.pbf",
              :headers => { "Host" => "planet.openstreetmap.org" },
              :ssl_verify => false) do
  its("status") { should eq 302 }
  its("headers.Location") { should eq "https://osm-planet-eu-central-1.s3.dualstack.eu-central-1.amazonaws.com/planet-full-history/pbf/2023/history-231016.osm.pbf" }
end

# Notes file

describe http("https://127.0.0.1/notes/2023/planet-notes-231222.osn.bz2",
              :headers => { "Host" => "planet.openstreetmap.org" },
              :ssl_verify => false) do
  its("status") { should eq 302 }
  its("headers.Location") { should eq "https://osm-planet-eu-central-1.s3.dualstack.eu-central-1.amazonaws.com/notes/osn/2023/planet-notes-231222.osn.bz2" }
end

describe http("https://127.0.0.1/notes/2023/planet-notes-231222.osn.bz2.md5",
              :headers => { "Host" => "planet.openstreetmap.org" },
              :ssl_verify => false) do
  its("status") { should eq 302 }
  its("headers.Location") { should eq "https://osm-planet-eu-central-1.s3.dualstack.eu-central-1.amazonaws.com/notes/osn/2023/planet-notes-231222.osn.bz2.md5" }
end

# Tiles log

describe http("https://127.0.0.1/tile_logs/tiles-2023-10-21.txt.xz",
              :headers => { "Host" => "planet.openstreetmap.org" },
              :ssl_verify => false) do
  its("status") { should eq 302 }
  its("headers.Location") { should eq "https://osm-planet-eu-central-1.s3.dualstack.eu-central-1.amazonaws.com/tile_logs/standard_layer/tiles/2023/tiles-2023-10-21.txt.xz" }
end
