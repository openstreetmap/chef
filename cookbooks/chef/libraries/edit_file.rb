class Chef
  class Recipe
    def edit_file(file, &block)
      ::File.new(file).collect do |line|
        line = yield line
      end.join("")
    end
  end
end
