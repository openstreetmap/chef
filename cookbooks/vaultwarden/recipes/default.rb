#
# Cookbook:: vaultwarden
# Recipe:: default
#
# Copyright:: 2026, OpenStreetMap Foundation
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

include_recipe "fail2ban"
include_recipe "podman::apache"

passwords = data_bag_item("vaultwarden", "passwords")

directory "/srv/vault.osmfoundation.org/data" do
  owner "root"
  group "root"
  mode "0777"
  recursive true
end

# TLS is terminated by apache, so the container only serves plain HTTP on
# its default port 80. The real client address is passed via X-Forwarded-For.
podman_site "vault.osmfoundation.org" do
  image "ghcr.io/dani-garcia/vaultwarden:latest"
  port 80
  environment "DOMAIN" => "https://vault.osmfoundation.org",
              "IP_HEADER" => "X-Forwarded-For",
              "SIGNUPS_ALLOWED" => "false",
              "INVITATIONS_ALLOWED" => "false",
              "ADMIN_TOKEN" => passwords["admin_token"],
              "SMTP_HOST" => "host.containers.internal",
              "SMTP_PORT" => "25",
              "SMTP_SECURITY" => "off",
              "SMTP_FROM" => "admins@openstreetmap.org",
              "SMTP_FROM_NAME" => "OpenStreetMap Admins",
              "EMAIL_2FA_ENFORCE_ON_VERIFIED_INVITE" => "true",
              "PUSH_ENABLED" => "true",
              "PUSH_INSTALLATION_ID" => passwords["push_installation_id"],
              "PUSH_INSTALLATION_KEY" => passwords["push_installation_key"],
              "PUSH_RELAY_URI" => "https://api.bitwarden.eu",
              "PUSH_IDENTITY_URI" => "https://identity.bitwarden.eu"
  volumes "/srv/vault.osmfoundation.org/data" => "/data"
end

fail2ban_filter "vaultwarden" do
  failregex [
    '^.*Username or password is incorrect\. Try again\. IP: <ADDR>\. Username: .*$',
    '^.*Invalid admin token\. IP: <ADDR>.*$'
  ]
end

fail2ban_jail "vaultwarden" do
  filter "vaultwarden"
  backend "systemd"
  journalmatch "_SYSTEMD_UNIT=vault.osmfoundation.org.service"
  ports [80, 443]
  maxretry 5
  bantime "1h"
end

template "/etc/cron.daily/vaultwarden-backup" do
  source "backup.cron.erb"
  owner "root"
  group "root"
  mode "755"
end
