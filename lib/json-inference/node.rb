module JsonInference
  class Node < BaseNode
    def initialize(name = nil, parent = nil)
      super()
      @name, @parent = name, parent
    end

    def selector
      "#{@parent.selector} > .#{@name}"
    end

    def selector_line(documents_count)
      "#{indent}#{selector}: #{total_count}/#{documents_count} (#{(total_count.to_f / documents_count * 100).round}%)\n"
    end

    def to_s(documents_count)
      str = ""
      str << selector_line(documents_count)
      @value_classes.each do |klass, count|
        str << "  #{indent}#{klass}: #{(count / total_count.to_f * 100).round}%\n"
      end
      each_sub_node do |sub_node|
        str << sub_node.to_s(documents_count)
      end
      str
    end
  end
end
