class Chef
  class Node
    def interfaces(options = {}, &block)
      interfaces = []

      networking = construct_attributes[:networking] || {}
      networking_interfaces = networking[:interfaces] || []

      networking_interfaces.each_value  do |interface|
        if options[:role].nil? or interface[:role].to_s == options[:role].to_s
          if options[:family].nil? or interface[:family].to_s == options[:family].to_s
            if block.nil?
              interfaces << interface
            else
              block.call(interface)
            end
          end
        end
      end

      interfaces
    end
  end
end
