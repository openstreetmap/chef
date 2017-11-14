#
# Cookbook Name:: ssl
# Resource:: ssl_certificate
#
# Copyright 2017, OpenStreetMap Foundation
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

property :certificate, String, :name_property => true
property :domains, [String, Array], :required => true

action :create do
  node.default[:letsencrypt][:certificates][certificate] = {
    :domains => Array(domains)
  }

  if letsencrypt
    certificate_content = letsencrypt["certificate"]
    key_content = letsencrypt["key"]
  end

  if certificate_content
    file "/etc/ssl/certs/#{certificate}.pem" do
      owner "root"
      group "root"
      mode 0o444
      content certificate_content
      backup false
      manage_symlink_source false
      force_unlink true
    end

    file "/etc/ssl/private/#{certificate}.key" do
      owner "root"
      group "ssl-cert"
      mode 0o440
      content key_content
      backup false
      manage_symlink_source false
      force_unlink true
    end
  else
    template "/tmp/#{certificate}.ssl.cnf" do
      cookbook "ssl"
      source "ssl.cnf.erb"
      owner "root"
      group "root"
      mode 0o644
      variables :domains => Array(domains)
      not_if do
        ::File.exist?("/etc/ssl/certs/#{certificate}.pem") && ::File.exist?("/etc/ssl/private/#{certificate}.key")
      end
    end

    execute "/etc/ssl/certs/#{certificate}.pem" do
      command "openssl req -x509 -newkey rsa:2048 -keyout /etc/ssl/private/#{certificate}.key -out /etc/ssl/certs/#{certificate}.pem -days 365 -nodes -config /tmp/#{certificate}.ssl.cnf"
      user "root"
      group "ssl-cert"
      not_if do
        ::File.exist?("/etc/ssl/certs/#{certificate}.pem") && ::File.exist?("/etc/ssl/private/#{certificate}.key")
      end
    end
  end
end

action :delete do
  file "/etc/ssl/certs/#{certificate}.pem" do
    action :delete
  end

  file "/etc/ssl/private/#{certificate}.key" do
    action :delete
  end
end

def letsencrypt
  @letsencrypt ||= search(:letsencrypt, "id:#{certificate}").first
end
