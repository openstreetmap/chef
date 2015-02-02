class Chef
  class Util
    def self.compare_versions(a, b)
      if a.is_a?(String)
        a = a.split(".").map(&:to_i)
      end

      if b.is_a?(String)
        b = b.split(".").map(&:to_i)
      end

      a <=> b
    end
  end
end
