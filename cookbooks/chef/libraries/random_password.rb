class Chef
  class Recipe
    def random_password(length)
      Array.new(length) do
        "!\#$%&()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[]^_`abcdefghijklmnopqrstuvwxyz{|}~"[rand(91)].chr
      end.join
    end
  end
end
