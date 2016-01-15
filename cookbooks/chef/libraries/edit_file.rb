class Chef
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

  class Recipe
    include Chef::Mixin::EditFile
  end
end
