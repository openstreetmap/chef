#
# Cookbook Name:: apt
# Provider:: apt_source
#
# Copyright 2015, OpenStreetMap Foundation
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

def whyrun_supported?
  true
end

use_inline_resources

action :create do
  if new_resource.key
    execute "apt-key-#{new_resource.key}" do
      command "/usr/bin/apt-key adv --keyserver hkp://keys.gnupg.net --recv-keys #{new_resource.key}"
      not_if "/usr/bin/apt-key list | /bin/fgrep -q #{new_resource.key}"
    end
  end

  template source_path  do
    source new_resource.template
    owner "root"
    group "root"
    mode 0644
    variables :url => new_resource.url
  end
end

action :delete do
  file source_path do
    action :delete
  end
end

def source_path
  "/etc/apt/sources.list.d/#{new_resource.name}.list"
end
