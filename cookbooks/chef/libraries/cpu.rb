module OpenStreetMap
  module Mixin
    module CPU
      def cpu_cores
        [self.dig("cpu", "total").to_i, self.dig("cpu", "cores").to_i, 4].max
      end
    end
  end
end

Chef::Node.include(OpenStreetMap::Mixin::CPU)
