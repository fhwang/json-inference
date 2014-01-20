module JsonInference
  def self.new_report
    Report.new
  end

  class BaseNode
    def initialize
      @value_classes = Hash.new 0
      @sub_nodes = Hash.new { |h,k| 
        if k == :nth_child
          sub_node = NthChildNode.new(self)
        else
          sub_node = Node.new(k, self)
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
      @value_classes.values.inject { |sum, i| sum + i }
    end
  end

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

  class NthChildNode < BaseNode
    def initialize(parent)
      super()
      @parent = parent
    end

    def selector
      "#{@parent.selector}:nth-child()"
    end

    def selector_line(documents_count)
      "#{indent}#{selector}: #{total_count} children total\n"
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

  class Report
    def initialize
      @documents = []
      @root = RootNode.new
    end

    def <<(document)
      @documents << document
      @root << document
    end

    def to_s
      str = "JsonInference report: #{@documents.size} documents total\n"
      str << @root.to_s(@documents.size)
      str
    end
  end
end
