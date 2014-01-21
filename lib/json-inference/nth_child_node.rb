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
      "#{indent}#{selector}: #{@values.size} child#{'ren' unless @values.size == 1}\n"
    end

    def to_s(documents_count)
      str = ""
      str << selector_line(documents_count)
      str << @values.to_s(indent)
      each_sub_node do |sub_node|
        str << sub_node.to_s(@values.size)
      end
      str
    end
  end
end
