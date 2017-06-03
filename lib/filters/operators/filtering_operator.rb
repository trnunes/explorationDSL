module Filtering
  module Operator
    class Comparator
      attr_accessor :expression
      def initialize(proc, expression)
        @proc = proc
        @expression = expression
      end
      def evaluate(item)
        @proc.call(item)
      end
    end
    
    def self.equal(value)
      Comparator.new(lambda{|item| item == value}, "item = #{value.to_s}")
    end
    
    def self.less_than(value)
      Comparator.new(lambda{|item| item.value < value.value}, "item < #{value.to_s}")
    end
    
    def self.greater_than(value)
      Comparator.new(lambda{|item| item.value > value.value}, "item > #{value.to_s}")
    end
    
    def self.less_than_equal(value)
      Comparator.new(lambda{|item| item.value <= value.value}, "item <= #{value.to_s}")
    end
    
    def self.greater_than_equal(value)
      Comparator.new(lambda{|item| item.value >= value.value}, "item >= #{value.to_s}")
    end
    
    def self.in(values_set)
      Comparator.new( lambda do |item| 
        # binding.pry
        found = false
        values_set.each do |value|
          
          if(item == value)
            found =  true
            break
          end
        end
        found
      end, "within: #{values_set.expression}")
    end
    
  end
  
  def self.op
    Filtering::Operator
  end
  
end