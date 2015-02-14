class Chef
  module Mixin
    module EditFile
      def edit_file(file, &block)
        Chef::DelayedEvaluator.new do
          ::File.new(file).collect do |line|
            block.call(line)
          end.join("")
        end
      end
    end
  end

  class Recipe
    include Chef::Mixin::EditFile
  end
end
