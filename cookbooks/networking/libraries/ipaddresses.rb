class Chef
  class Node
    def ipaddresses(options = {}, &block)
      addresses = []

      interfaces(options).each do |interface|
        address = interface[:public_address] || interface[:address]

        if block.nil?
          addresses << address
        else
          yield address
        end
      end

      addresses
    end

    def internal_ipaddress
      ipaddresses(:role => :internal).first
    end

    def external_ipaddress
      ipaddresses(:role => :external).first
    end
  end
end
