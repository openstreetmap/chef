class Chef
  class Util
    def self.compare_versions(a, b)
      a = a.split(".").map(&:to_i) if a.is_a?(String)

      b = b.split(".").map(&:to_i) if b.is_a?(String)

      a <=> b
    end
  end
end
