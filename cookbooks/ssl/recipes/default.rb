#
# Cookbook Name:: ssl
# Recipe:: default
#
# Copyright 2011, OpenStreetMap Foundation
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

keys = data_bag_item("ssl", "keys")

package "openssl"
package "ssl-cert"

cookbook_file "/etc/ssl/certs/rapidssl.pem" do
  owner "root"
  group "root"
  mode 0444
  backup false
end

[ "openstreetmap", "tile.openstreetmap", "crm.osmfoundation" ].each do |certificate|
  if node[:ssl][:certificates].include?(certificate)
    cookbook_file "/etc/ssl/certs/#{certificate}.pem" do
      owner "root"
      group "root"
      mode 0444
      backup false
    end

    file "/etc/ssl/private/#{certificate}.key" do
      owner "root"
      group "ssl-cert"
      mode 0440
      content keys[certificate].join("\n")
      backup false
    end
  else
    file "/etc/ssl/certs/#{certificate}.pem" do
      action :delete
    end

    file "/etc/ssl/private/#{certificate}.key" do
      action :delete
    end
  end
end
