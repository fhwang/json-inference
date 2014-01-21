module JsonInference
  def self.new_report
    Report.new
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
end
 
dir = File.dirname(__FILE__) + "/json-inference"
require "#{dir}/base_node"
require "#{dir}/node"
require "#{dir}/nth_child_node"
require "#{dir}/root_node"
