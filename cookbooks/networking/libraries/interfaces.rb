class Chef
  class Node
    def interfaces(options = {}, &block)
      interfaces = []

      networking = construct_attributes[:networking] || {}
      networking_interfaces = networking[:interfaces] || {}

      networking_interfaces.each_value  do |interface|
        next unless options[:role].nil? || interface[:role].to_s == options[:role].to_s
        next unless options[:family].nil? || interface[:family].to_s == options[:family].to_s

        if block.nil?
          interfaces << interface
        else
          yield interface
        end
      end

      interfaces
    end
  end
end
