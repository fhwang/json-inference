module JsonInference
  class NthChildNode < BaseNode
    def initialize(parent)
      super()
      @parent = parent
    end

    def selector
      "#{@parent.selector}:nth-child()"
    end

    def selector_line(documents_count)
      "#{indent}#{selector}: #{total_count} child#{'ren' unless total_count == 1}\n"
    end

    def to_s(documents_count)
      str = ""
      str << selector_line(documents_count)
      @value_classes.each do |klass, count|
        str << "  #{indent}#{klass}: #{(count / total_count.to_f * 100).round}%\n"
      end
      each_sub_node do |sub_node|
        str << sub_node.to_s(total_count)
      end
      str
    end
  end
end
