#
# Cookbook Name:: apt
# Definition:: apt_source
#
# Copyright 2010, Tom Hughes
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

define :apt_source do
  if node.apt.sources.include?(params[:name])
    source_action = :create

    if params[:key]
      execute "apt-key-#{params[:key]}" do
        command "/usr/bin/apt-key adv --keyserver hkp://keys.gnupg.net --recv-keys #{params[:key]}"
        not_if "/usr/bin/apt-key list | /bin/fgrep -q #{params[:key]}"
      end
    end
  else
    source_action = :delete
  end

  template "/etc/apt/sources.list.d/#{params[:name]}.list" do
    action source_action
    source params[:template] || "default.list.erb"
    owner "root"
    group "root"
    mode 0644
    notifies :run, resources(:execute => "apt-update")
    variables :url => params[:url]
  end
end
