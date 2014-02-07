module JsonInference
  def self.new_report
    Report.new
  end

  def self.percent_string(numerator, denominator)
    sprintf("%.2f%", numerator / denominator.to_f * 100)
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
      str = "JsonInference report: #{@documents.size} documents\n"
      str << @root.to_s(@documents.size)
      str
    end
  end

  class NodeValuesCollection
    def initialize
      @value_counters = Hash.new { |h,k| h[k] = ValueCounter.new(k) }
    end

    def <<(value)
      if value.class == String && value =~ /^(\d){4}-(\d){2}-(\d){2}T(\d){2}:(\d){2}:(\d){2}\.(\d){3}Z$/
        @value_counters[Date] << value
      elsif [true, false].include?(value)
        @value_counters['Boolean'] << value
      else
        @value_counters[value.class] << value
      end
    end

    def size
      @value_counters.values.inject(0) { |sum, counter| sum + counter.size } || 0
    end

    def to_s(indent)
      str = ""
      @value_counters.values.each do |value_counter|
        str << "  #{indent}#{value_counter.to_s(size)}\n"
      end
      str
    end

    class ValueCounter
      attr_reader :size

      def initialize(reported_class)
        @reported_class = reported_class
        @size = 0
        @empties = 0
        @values_by_count = Hash.new(0)
      end

      def <<(value)
        @values_by_count[value] += 1
        @size += 1
        if [Array, String].include?(@reported_class)
          @empties += 1 if value.empty?
        end
      end

      def to_s(all_values_count)
        str = "#{@reported_class}: #{JsonInference.percent_string(size, all_values_count)}"
        primary_value_record = @values_by_count.detect { |value, count|
          count / size.to_f >= 0.9
        }
        if primary_value_record
          primary_value, count = primary_value_record
          str << ", #{JsonInference.percent_string(count, size)} #{primary_value.inspect}"
        end
        if [Array, String].include?(@reported_class)
          str << ", #{JsonInference.percent_string(@empties, size)} empty"
        end
        str
      end
    end
  end
end
 
dir = File.dirname(__FILE__) + "/json-inference"
require "#{dir}/base_node"
require "#{dir}/node"
require "#{dir}/nth_child_node"
require "#{dir}/root_node"
