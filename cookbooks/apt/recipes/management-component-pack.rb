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
  # Force re-download of keyring
  file "/etc/apt/keyrings/mcp.gpg" do
    action :delete
    only_if { ::File.exist?("/etc/apt/keyrings/mcp.gpg") && ::File.mtime("/etc/apt/keyrings/mcp.gpg").to_date < Date.new(2025, 12, 9) }
  end
  apt_repository "mcp" do
    uri "https://downloads.linux.hpe.com/SDR/repo/mcp"
    distribution "#{node[:lsb][:codename]}/current"
    components ["non-free"]
    key ["https://downloads.linux.hpe.com/SDR/hpePublicKey2048_key1.pub", "https://downloads.linux.hpe.com/SDR/hpePublicKey2048_key2.pub"]
  end

  if node.dig(:dmi, :system, :product_name).to_s.end_with?("Gen9")
    # Force re-download of keyring
    file "/etc/apt/keyrings/mcp-gen9.gpg" do
      action :delete
      only_if { ::File.exist?("/etc/apt/keyrings/mcp-gen9.gpg") && ::File.mtime("/etc/apt/keyrings/mcp-gen9.gpg").to_date < Date.new(2025, 12, 9) }
    end
    apt_repository "mcp-gen9" do
      uri "https://downloads.linux.hpe.com/SDR/repo/mcp"
      distribution "stretch/current-gen9"
      components ["non-free"]
      key ["https://downloads.linux.hpe.com/SDR/hpePublicKey2048_key1.pub", "https://downloads.linux.hpe.com/SDR/hpePublicKey2048_key2.pub"]
    end
  end
elsif platform?("ubuntu")
  if node.dig(:dmi, :system, :product_name).to_s.end_with?("Gen10")
    # Force re-download of keyring
    file "/etc/apt/keyrings/mcp-jammy.gpg" do
      action :delete
      only_if { ::File.exist?("/etc/apt/keyrings/mcp-jammy.gpg") && ::File.mtime("/etc/apt/keyrings/mcp-jammy.gpg").to_date < Date.new(2025, 12, 9) }
    end
    apt_repository "mcp-jammy" do
      uri "https://downloads.linux.hpe.com/SDR/repo/mcp"
      distribution "jammy/current"
      components ["non-free"]
      key ["https://downloads.linux.hpe.com/SDR/hpePublicKey2048_key1.pub", "https://downloads.linux.hpe.com/SDR/hpePublicKey2048_key2.pub"]
    end

    # Force re-download of keyring
    file "/etc/apt/keyrings/mcp-focal-gen10.gpg" do
      action :delete
      only_if { ::File.exist?("/etc/apt/keyrings/mcp-focal-gen10.gpg") && ::File.mtime("/etc/apt/keyrings/mcp-focal-gen10.gpg").to_date < Date.new(2025, 12, 9) }
    end
    apt_repository "mcp-focal-gen10" do
      uri "https://downloads.linux.hpe.com/SDR/repo/mcp"
      distribution "focal/current-gen10"
      components ["non-free"]
      key ["https://downloads.linux.hpe.com/SDR/hpePublicKey2048_key1.pub", "https://downloads.linux.hpe.com/SDR/hpePublicKey2048_key2.pub"]
    end
  else
    # Force re-download of keyring
    file "/etc/apt/keyrings/mcp-bionic-gen9.gpg" do
      action :delete
      only_if { ::File.exist?("/etc/apt/keyrings/mcp-bionic-gen9.gpg") && ::File.mtime("/etc/apt/keyrings/mcp-bionic-gen9.gpg").to_date < Date.new(2025, 12, 9) }
    end
    apt_repository "mcp-bionic-gen9" do
      uri "https://downloads.linux.hpe.com/SDR/repo/mcp"
      distribution "bionic/current-gen9"
      components ["non-free"]
      key ["https://downloads.linux.hpe.com/SDR/hpePublicKey2048_key1.pub", "https://downloads.linux.hpe.com/SDR/hpePublicKey2048_key2.pub"]
    end
  end
end
