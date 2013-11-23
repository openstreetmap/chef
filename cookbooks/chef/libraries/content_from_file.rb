class Chef
  class Resource
    class File
      def content_from_file(file, &block)
        @content_file = file
        @content_block = block
      end

      def content(text = nil)
        if text
          @content = text
        elsif @content
          @content
        elsif @content_file
          ::File.new(@content_file).collect do |line|
            line = @content_block.call(line)
          end.join("")
        end
      end
    end
  end
end
