class Chef
  class Recipe
    def random_password(length)
      length.times.collect do
        "!\#$%&()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[]^_`abcdefghijklmnopqrstuvwxyz{|}~"[rand(91)].chr
      end.join
    end
  end
end
