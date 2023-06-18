module OpenStreetMap
  module Mixin
    module Interfaces
      def interfaces(role: nil)
        networking = construct_attributes[:networking] || {}
        networking_interfaces = networking[:interfaces] || {}

        networking_interfaces.each_value.select do |interface|
          role.nil? || interface[:role].to_s == role.to_s
        end
      end
    end
  end
end

Chef::Node.include(OpenStreetMap::Mixin::Interfaces)
