#
# Cookbook Name:: apt
# Resource:: apt_source
#
# Copyright 2015, OpenStreetMap Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default_action :create

property :source_name, String, :name_property => true
property :source_template, String, :default => "default.list.erb"
property :url, String, :required => true
property :key, String
property :key_url, String
property :update, [TrueClass, FalseClass], :default => false

def initialize(name, run_context = nil)
  super(name, run_context)

  @action = node[:apt][:sources].include?(name) ? :create : :delete
end

action :create do
  if new_resource.key
    execute "apt-key-#{new_resource.key}-clean" do
      command "/usr/bin/apt-key adv --batch --delete-key --yes #key}"
      only_if "/usr/bin/apt-key adv --list-keys #{new_resource.key} | fgrep expired"
    end

    if new_resource.key_url
      execute "apt-key-#{new_resource.key}-install" do
        command "/usr/bin/apt-key adv --fetch-keys #{new_resource.key_url}"
        not_if "/usr/bin/apt-key adv --list-keys #{new_resource.key}"
        notifies :run, "execute[apt-update-#{new_resource.source_name}]"
      end
    else
      execute "apt-key-#{new_resource.key}-install" do
        command "/usr/bin/apt-key adv --keyserver hkp://keys.gnupg.net --recv-keys #{new_resource.key}"
        not_if "/usr/bin/apt-key adv --list-keys #{new_resource.key}"
        notifies :run, "execute[apt-update-#{new_resource.source_name}]"
      end
    end
  end

  template source_path do
    source new_resource.source_template
    owner "root"
    group "root"
    mode 0o644
    variables :url => new_resource.url
    notifies :run, "execute[apt-update-#{new_resource.source_name}]"
  end

  execute "apt-update-#{new_resource.source_name}" do
    action new_resource.update ? :run : :nothing
    command "/usr/bin/apt-get update --no-list-cleanup -o Dir::Etc::sourcelist='#{source_path}' -o Dir::Etc::sourceparts='-'"
  end
end

action :delete do
  file source_path do
    action :delete
  end
end

action_class do
  def source_path
    "/etc/apt/sources.list.d/#{new_resource.source_name}.list"
  end
end
