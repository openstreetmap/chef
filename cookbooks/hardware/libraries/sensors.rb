class Chef
  class Sensors
    def self.attributes(sensors, attribute_names)
      sensors ||= {}
      results = []

      sensors.sort.each do |sensor, attributes|
        if attributes[:ignore]
          results << "ignore #{sensor}"
        else
          results << "label #{sensor} \"#{attributes[:label]}\"" if attributes[:label]
          results << "compute #{sensor} #{attributes[:compute]}" if attributes[:compute]

          attribute_names.each do |name|
            results << "set #{sensor}_#{name} #{attributes[name]}" if attributes[name]
          end
        end
      end

      results.map { |r| "  #{r}\n" }.join("")
    end
  end
end
