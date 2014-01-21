module JsonInference
  class BaseNode
    def initialize
      @values = NodeValuesCollection.new
      @sub_nodes = Hash.new { |h,k| 
        if k == :nth_child
          sub_node = JsonInference::NthChildNode.new(self)
        else
          sub_node = JsonInference::Node.new(k, self)
        end
        h[k] = sub_node
      }
    end

    def <<(value)
      if value.is_a?(Hash)
        value.each do |key, sub_value|
          @sub_nodes[key] << sub_value
        end
      elsif value.is_a?(Array)
        @sub_nodes[:nth_child]
        value.each do |sub_value|
          @sub_nodes[:nth_child] << sub_value
        end
      end
      @values << value
    end

    def each_sub_node
      @sub_nodes.keys.sort.each do |key|
        sub_node = @sub_nodes[key]
        yield sub_node
      end
    end

    def indent_level
      @parent.indent_level + 1
    end

    def indent
      '  ' * indent_level
    end
  end
end
