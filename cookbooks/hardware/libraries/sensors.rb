class Chef
  class Sensors
    def self.attributes(sensors, attribute_names)
      sensors ||= {}
      results = []

      sensors.sort.each do |sensor, attributes|
        if attributes[:ignore]
          results << "ignore #{sensor}"
        else
          if label = attributes[:label]
            resuls << "label #{sensor} \"#{label}\""
          end

          if compute = attributes[:compute]
            resuls << "compute #{sensor} #{compute}"
          end

          attribute_names.each do |name|
            if value = attributes[name]
              results << "set #{sensor}_#{name} #{value}"
            end
          end
        end
      end

      results.map { |r| "  #{r}\n" }.join("")
    end
  end
end
