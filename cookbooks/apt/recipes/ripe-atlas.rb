#
# Cookbook:: apt
# Recipe:: ripe-atlas
#
# Copyright:: 2025, Grant Slater
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

include_recipe "apt"

if platform?("debian")
  apt_repository "ripe-atlas" do
    uri "https://ftp.ripe.net/ripe/atlas/software-probe/debian/"
    components ["main"]
    key "https://raw.githubusercontent.com/RIPE-NCC/ripe-atlas-software-probe/refs/heads/master/.repo/RPM-GPG-KEY-ripe-atlas-20240924.master"
  end

  # Alternative is to install the ripe-atlas-repo package for setting up the repository
  # package "ripe-atlas-repo"
end
