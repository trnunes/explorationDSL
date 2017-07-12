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
    
    def self.requal(relation, value)
      Comparator.new(lambda{|item| relation[[item]].include?(value)}, "relation[item] = #{value.to_s}")
    end
    
    def self.less_than(value)
      Comparator.new(lambda{|item| item.value < value.value}, "item < #{value.to_s}")
    end
    
    def self.rless_than(relation, value)
      code = "relation[item].value < #{value.to_s}"
      Comparator.new(lambda{|item| relation[[item]].value < value.value}, code)
    end
    
    def self.greater_than(value)
      Comparator.new(lambda{|item| item.value > value.value}, "item > #{value.to_s}")
    end
    
    def self.rgreater_than(relation, value)
      Comparator.new(lambda{|item| relation[[item]].value > value.value}, "relation[item] > #{value.to_s}")
    end
    
    
    def self.less_than_equal(value)
      Comparator.new(lambda{|item| item.value <= value.value}, "item <= #{value.to_s}")
    end
    
    def self.rless_than_equal(relation, value)
      Comparator.new(lambda{|item| relation[[item]].value <= value.value}, "relation[item] <= #{value.to_s}")
    end
        
    def self.greater_than_equal(value)
      Comparator.new(lambda{|item| item.value >= value.value}, "item >= #{value.to_s}")
    end
    
    def self.rgreater_than_equal(relation, value)
      Comparator.new(lambda{|item| relation[[item]].value >= value.value}, "relation[item] >= #{value.to_s}")
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
    
    def self.rin(relation, values_set)
      Comparator.new(lambda do |item| 
        !(relation[[item]] & values_set.each).empty?
      end, "within: #{values_set.expression}")
    end
    
    
  end
  
  def self.op
    Filtering::Operator
  end
  
end