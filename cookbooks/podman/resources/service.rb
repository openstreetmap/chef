#
# Cookbook:: podman
# Resource:: podman_service
#
# Copyright:: 2023, OpenStreetMap Foundation
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

require "yaml"

unified_mode true

default_action :create

property :service, String, :name_property => true
property :description, String, :required => true
property :image, String, :required => true
property :ports, Hash, :default => {}
property :environment, Hash, :default => {}
property :volumes, Hash, :default => {}
property :pids_limit, Integer
property :command, String

action :create do
  mounts = volume_mounts
  mapping = id_mapping

  new_resource.volumes.each do |source, options|
    next unless options.is_a?(Hash)

    directory ::File.dirname(source) do
      owner "root"
      group "root"
      mode "0755"
      recursive true
      not_if { ::Dir.exist?(::File.dirname(source)) }
    end

    directory source do
      owner mapping + options.fetch(:uid, 0)
      group mapping + options.fetch(:gid, 0)
      mode options.fetch(:mode, "0700")
    end
  end

  systemd_container new_resource.service do
    description new_resource.description
    image new_resource.image
    command new_resource.command
    ports new_resource.ports
    environment new_resource.environment
    volumes mounts
    pids_limit new_resource.pids_limit
    uid_map "0:#{mapping}:65536"
    gid_map "0:#{mapping}:65536"
    timeout_start_sec 180
    restart "on-failure"
  end

  # No action :start here to avoid a start and then immediate :restart, due to subscribe, on first run
  service new_resource.service do
    action :nothing
    subscribes :restart, "systemd_container[#{new_resource.service}]", :immediately
  end

  # Ensure the service is started if not running, replies on status of service resource
  notify_group new_resource.service do
    action :run
    notifies :start, "service[#{new_resource.service}]", :immediately
  end
end

action :delete do
  service new_resource.service do
    action [:disable, :stop]
  end

  systemd_container new_resource.service do
    action :delete
  end
end

action_class do
  def volume_mounts
    new_resource.volumes.to_h do |source, options|
      if options.is_a?(Hash)
        valid = source.is_a?(String) && source.start_with?("/") &&
                options[:target].is_a?(String) && options[:target].start_with?("/") &&
                (options.keys - [:target, :uid, :gid, :mode]).empty? &&
                [:uid, :gid].all? { |key| options.fetch(key, 0).is_a?(Integer) && options.fetch(key, 0).between?(0, 65535) } &&
                options.fetch(:mode, "0700").is_a?(String) && options.fetch(:mode, "0700").match?(/\A[0-7]{3,4}\z/)

        raise "Invalid managed volume #{source.inspect} for #{new_resource.service}" unless valid

        [source, options[:target]]
      elsif options.is_a?(String)
        [source, options]
      else
        raise "Invalid volume #{source.inspect} for #{new_resource.service}"
      end
    end
  end

  def mappings_file
    "/var/lib/podman/mappings.yml"
  end

  def read_mappings
    mappings = ::File.exist?(mappings_file) ? YAML.safe_load_file(mappings_file) : {}

    valid = mappings.is_a?(Hash) && mappings.all? do |name, base|
      name.is_a?(String) && base.is_a?(Integer) &&
        base >= 3221225472 && (base % 65536).zero?
    end

    unless valid && mappings.values.uniq.size == mappings.size
      raise "Invalid Podman ID mappings in #{mappings_file}"
    end

    mappings
  end

  def allocate_mapping(mappings)
    return mappings[new_resource.service] if mappings.include?(new_resource.service)

    base = 3221225472
    base += 65536 while mappings.values.include?(base)

    mappings[new_resource.service] = base
  end

  def id_mapping
    mappings = read_mappings
    return mappings[new_resource.service] if mappings.include?(new_resource.service)

    base = allocate_mapping(mappings)

    converge_by("Allocate Podman UID/GID range for #{new_resource.service}") do
      ::File.open(mappings_file, "w", 0600) do |file|
        file.write(YAML.dump(mappings))
      end
    end

    base
  end

  def publish_options
    new_resource.ports.collect do |host, guest|
      "--publish=127.0.0.1:#{host}:#{guest}"
    end.join(" ")
  end

  def environment_options
    new_resource.environment.collect do |key, value|
      "-e '#{key}=#{value}'"
    end.join(" ")
  end

  def volume_options
    volume_mounts.collect do |key, value|
      "-v '#{key}:#{value}'"
    end.join(" ")
  end
end
