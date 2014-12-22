#
# Cookbook Name:: planet
# Recipe:: dump
#
# Copyright 2013, OpenStreetMap Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

node.default[:incron][:planetdump] = {
  :user => "www-data",
  :path => "/store/backup",
  :events => [ "IN_CREATE", "IN_MOVED_TO" ],
  :command => "/usr/local/bin/planetdump $#"
}

include_recipe "git"
include_recipe "incron"

package "gcc"
package "make"
package "autoconf"
package "automake"
package "libxml2-dev"
package "libboost-dev"
package "libboost-program-options-dev"
package "libboost-date-time-dev"
package "libboost-filesystem-dev"
package "libboost-thread-dev"
package "libboost-iostreams-dev"
package "libosmpbf-dev"
package "libprotobuf-dev"
package "osmpbf-bin"

directory "/opt/planet-dump-ng" do
  owner "root"
  group "root"
  mode 0755
end

git "/opt/planet-dump-ng" do
  action :sync
  repository "git://github.com/zerebubuth/planet-dump-ng.git"
  revision "master"
  user "root"
  group "root"
end

execute "/opt/planet-dump-ng/autogen.sh" do
  action :nothing
  command "./autogen.sh"
  cwd "/opt/planet-dump-ng"
  user "root"
  group "root"
  subscribes :run, "git[/opt/planet-dump-ng]"
end

execute "/opt/planet-dump-ng/configure" do
  action :nothing
  command "./configure"
  cwd "/opt/planet-dump-ng"
  user "root"
  group "root"
  subscribes :run, "execute[/opt/planet-dump-ng/autogen.sh]"
end

execute "/opt/planet-dump-ng/Makefile" do
  action :nothing
  command "make"
  cwd "/opt/planet-dump-ng"
  user "root"
  group "root"
  subscribes :run, "execute[/opt/planet-dump-ng/configure]"
end

directory "/store/planetdump" do
  owner "www-data"
  group "www-data"
  mode 0755
end

["planetdump", "planet-mirror-redirect-update", "apache-latest-planet-filename"].each do |program|
  template "/usr/local/bin/#{program}" do
    source "#{program}.erb"
    owner "root"
    group "root"
    mode 0755
  end
end
