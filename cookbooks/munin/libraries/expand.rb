class Chef
  class Munin
    def self.expand(template, nodes, separator = " ")
      nodes.map do |node|
        if node.is_a?(Hash)
          template
            .gsub(/%%%([^%]+)%%%/) { node[Regexp.last_match[1].to_sym].tr("-", "_") }
            .gsub(/%%([^%]+)%%/) { node[Regexp.last_match[1].to_sym] }
        else
          template
            .gsub("%%%", node.tr("-", "_"))
            .gsub("%%", node)
        end
      end.join(separator)
    end
  end
end
