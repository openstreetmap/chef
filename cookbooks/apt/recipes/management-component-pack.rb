#
# Cookbook:: apt
# Recipe:: management-component-pack
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

apt_repository "management-component-pack" do
  action :remove
end

if platform?("debian")
  distribution = if node[:lsb][:release].to_f > 12
                   "bookworm"
                 else
                   node[:lsb][:codename]
                 end

  legacy_key_options = if node[:lsb][:release].to_f > 12
                         ["allow-insecure=yes"]
                       else
                         []
                       end

  if node[:platform_version].to_i >= 13
    # First remove the repo if the keyring is in the unsupported keybox database format
    # Use apt_repository to remove the repository to ensure apt update is triggered later
    apt_repository "mcp-remove" do
      action :remove
      repo_name "mcp"
      only_if { ::File.exist?("/etc/apt/keyrings/mcp.gpg") && ::File.binread("/etc/apt/keyrings/mcp.gpg", 12)[8..11] == "KBXf" }
    end
  end

  apt_repository "mcp" do
    uri "https://downloads.linux.hpe.com/SDR/repo/mcp"
    distribution "#{distribution}/current"
    components ["non-free"]
    key "https://downloads.linux.hpe.com/SDR/hpePublicKey2048_key2.pub"
  end
  if node.dig(:dmi, :system, :product_name).to_s.end_with?("Gen9")
    if node[:platform_version].to_i >= 13
      # First remove the repo if the keyring is in the unsupported keybox database format
      # Use apt_repository to remove the repository to ensure apt update is triggered later
      apt_repository "mcp-gen9-remove" do
        action :remove
        repo_name "mcp-gen9"
        only_if { ::File.exist?("/etc/apt/keyrings/mcp-gen9.gpg") && ::File.binread("/etc/apt/keyrings/mcp-gen9.gpg", 12)[8..11] == "KBXf" }
      end
    end

    apt_repository "mcp-gen9" do
      uri "https://downloads.linux.hpe.com/SDR/repo/mcp"
      distribution "stretch/current-gen9"
      components ["non-free"]
      key "https://downloads.linux.hpe.com/SDR/hpePublicKey2048_key1.pub"
      options legacy_key_options
    end
  end
elsif platform?("ubuntu")
  if node.dig(:dmi, :system, :product_name).to_s.end_with?("Gen10")
    apt_repository "mcp-jammy" do
      uri "https://downloads.linux.hpe.com/SDR/repo/mcp"
      distribution "jammy/current"
      components ["non-free"]
      key ["https://downloads.linux.hpe.com/SDR/hpePublicKey2048_key1.pub", "https://downloads.linux.hpe.com/SDR/hpePublicKey2048_key2.pub"]
    end

    apt_repository "mcp-focal-gen10" do
      uri "https://downloads.linux.hpe.com/SDR/repo/mcp"
      distribution "focal/current-gen10"
      components ["non-free"]
      key ["https://downloads.linux.hpe.com/SDR/hpePublicKey2048_key1.pub", "https://downloads.linux.hpe.com/SDR/hpePublicKey2048_key2.pub"]
    end
  else
    apt_repository "mcp-bionic-gen9" do
      uri "https://downloads.linux.hpe.com/SDR/repo/mcp"
      distribution "bionic/current-gen9"
      components ["non-free"]
      key ["https://downloads.linux.hpe.com/SDR/hpePublicKey2048_key1.pub", "https://downloads.linux.hpe.com/SDR/hpePublicKey2048_key2.pub"]
    end
  end
end
