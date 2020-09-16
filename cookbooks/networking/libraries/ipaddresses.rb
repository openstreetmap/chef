class Chef
  class Node
    def ipaddresses(options = {}, &block)
      addresses = []

      interfaces(options).each do |interface|
        address = interface[:public_address] || interface[:address]

        next if address.nil?

        if block.nil?
          addresses << address
        else
          yield address
        end
      end

      addresses
    end

    def internal_ipaddress(options = {})
      ipaddresses(options.merge(:role => :internal)).first
    end

    def external_ipaddress(options = {})
      ipaddresses(options.merge(:role => :external)).first
    end
  end
end
