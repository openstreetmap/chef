class Chef
  class Node
    def ipaddresses(options = {}, &block)
      addresses = []

      interfaces(options).each do |interface|
        if block.nil?
          addresses << interface[:address]
        else
          yield interface[:address]
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
