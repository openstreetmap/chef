#
# Cookbook:: stateofthemap
# Recipe:: default
#
# Copyright:: 2013, OpenStreetMap Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

git "/srv/stateofthemap.org" do
  action :sync
  repository "https://git.openstreetmap.org/public/stateofthemap.git"
  revision "chooser"
  depth 1
  user "root"
  group "root"
end

ssl_certificate "stateofthemap.org" do
  domains ["stateofthemap.org", "www.stateofthemap.org",
           "stateofthemap.com", "www.stateofthemap.com",
           "sotm.org", "www.sotm.org"]
  notifies :reload, "service[apache2]"
end

apache_site "stateofthemap.org" do
  template "apache.erb"
  directory "/srv/stateofthemap.org"
end
