#
# Cookbook:: stateofthemap
# Recipe:: static
#
# Copyright:: 2022, OpenStreetMap Foundation
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

include_recipe "stateofthemap"

%w[2013].each do |year|
  git "/srv/#{year}.stateofthemap.org" do
    action :sync
    repository "https://git.openstreetmap.org/public/stateofthemap.git"
    revision "site-#{year}"
    depth 1
    user "root"
    group "root"
  end

  ssl_certificate "#{year}.stateofthemap.org" do
    domains ["#{year}.stateofthemap.org", "#{year}.stateofthemap.com", "#{year}.sotm.org"]
    notifies :reload, "service[apache2]"
  end

  apache_site "#{year}.stateofthemap.org" do
    template "apache.static.erb"
    directory "/srv/#{year}.stateofthemap.org"
    variables :year => year
  end
end
