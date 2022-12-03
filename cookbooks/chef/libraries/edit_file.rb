module OpenStreetMap
  module Mixin
    module EditFile
      def edit_file(file, &_block)
        Chef::DelayedEvaluator.new do
          ::File.new(file).collect do |line|
            yield line
          end.join("")
        end
      end
    end
  end
end

Chef::Recipe.include(OpenStreetMap::Mixin::EditFile)
