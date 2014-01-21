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
      "#{indent}#{selector}: #{@values.size}/#{documents_count} (#{JsonInference.percent_string(@values.size, documents_count)})\n"
    end

    def to_s(documents_count)
      str = ""
      str << selector_line(documents_count)
      str << @values.to_s(indent)
      each_sub_node do |sub_node|
        str << sub_node.to_s(documents_count)
      end
      str
    end
  end
end
