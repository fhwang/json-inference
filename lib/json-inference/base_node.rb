module JsonInference
  class BaseNode
    def initialize
      @value_classes = Hash.new 0
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
      if value.class == String && value =~ /^(\d){4}-(\d){2}-(\d){2}T(\d){2}:(\d){2}:(\d){2}\.(\d){3}Z$/
        @value_classes[Date] += 1
      elsif [true, false].include?(value)
        @value_classes['Boolean'] += 1
      else
        @value_classes[value.class] += 1
      end
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

    def total_count
      @value_classes.values.inject { |sum, i| sum + i } || 0
    end
  end
end
