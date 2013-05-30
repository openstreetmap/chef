class Chef
  class Munin
    def self.expand(template, nodes)
      nodes.map do |node| 
        if node.kind_of?(Hash)
          template.gsub(/%%([^%]+)%%/) { node[$1.to_sym] }
        else
          template.gsub("%%", node)
        end
      end.join(" ")
    end
  end 
end
