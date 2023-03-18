require "ipaddr"

module OpenStreetMap
  module Mixin
    module IPAddresses
      class Address
        attr_reader :address, :prefix, :gateway, :network, :netmask

        def initialize(address)
          @address = address[:public_address] || address[:address]
          @prefix = address[:prefix]
          @gateway = address[:gateway]

          ip = IPAddr.new(address[:address]).mask(address[:prefix])

          @network = ip.to_s
          @netmask = ip.netmask
        end

        def <=>(other)
          address <=> other.address
        end

        def to_s
          address
        end

        def to_str
          address
        end

        def subnet
          "#{@network}/#{@prefix}"
        end
      end

      def ipaddresses(role: nil, family: nil)
        interfaces(:role => role).each_with_object([]) do |interface, addresses|
          addresses << Address.new(interface[:inet]) if interface[:inet] && (family.nil? || family == :inet)
          addresses << Address.new(interface[:inet6]) if interface[:inet6] && (family.nil? || family == :inet6)
        end
      end

      def internal_ipaddress(family: nil)
        ipaddresses(:role => :internal, :family => family).first
      end

      def external_ipaddress(family: nil)
        ipaddresses(:role => :external, :family => family).first
      end
    end
  end
end

Chef::Node.include(OpenStreetMap::Mixin::IPAddresses)
