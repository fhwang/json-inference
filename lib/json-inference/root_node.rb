module JsonInference
  class RootNode < BaseNode
    def indent_level
      -1
    end

    def selector
      ':root'
    end

    def to_s(documents_count)
      str = ""
      each_sub_node do |sub_node|
        str << sub_node.to_s(documents_count)
        str << "\n"
      end
      str
    end
  end
end
