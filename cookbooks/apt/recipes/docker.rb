#
# Cookbook:: apt
# Recipe:: docker
#
# Copyright:: 2022, Tom Hughes
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

docker_platform = if platform?("debian")
                    "debian"
                  else
                    "ubuntu"
                  end

docker_arch = if arm?
                "arm64"
              else
                "amd64"
              end

apt_repository "docker" do
  uri "https://download.docker.com/linux/#{docker_platform}"
  arch docker_arch
  components ["stable"]
  key "https://download.docker.com/linux/#{docker_platform}/gpg"
end
