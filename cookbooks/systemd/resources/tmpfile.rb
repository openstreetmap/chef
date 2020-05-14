#
# Cookbook:: systemd
# Resource:: systemd_tmpfile
#
# Copyright:: 2016, OpenStreetMap Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default_action :create

property :type, String, :required => [:create]
property :path, String, :name_property => true
property :mode, String, :default => "-"
property :owner, String, :default => "-"
property :group, String, :default => "-"
property :age, String, :default => "-"
property :argument, String, :default => "-"

action :create do
  template "/etc/tmpfiles.d/#{unit_name}.conf" do
    cookbook "systemd"
    source "tmpfile.erb"
    owner "root"
    group "root"
    mode "644"
    variables new_resource.to_hash.merge(:path => new_resource.path)
  end

  execute "systemd-tmpfiles" do
    action :nothing
    command "systemd-tmpfiles --create /etc/tmpfiles.d/#{unit_name}.conf"
    user "root"
    group "root"
    subscribes :run, "template[/etc/tmpfiles.d/#{unit_name}.conf]"
  end
end

action :delete do
  file "/etc/tmpfiles.d/#{unit_name}.conf" do
    action :delete
  end
end

action_class do
  def unit_name
    new_resource.path.sub(%r{^/}, "").gsub(%r{/}, "-")
  end
end
