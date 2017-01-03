
module Filtering
  class Equals < Filtering::Filter
    def initialize(*args)
      super(args)
      
      if args.size == 1
        @value = args[0]
      elsif args.size == 2
        @relation = args[0]
        @value = args[1]
      else
        raise "Invalid number of arguments. Expected: min 1, max 2; Received: #{args.size}"
      end      
    end
    
    def eval(set)
      extension = set.extension_copy
      if(@relation.nil?)
        if set.empty_image?
          set.each_domain.select{|item| !(item.eql?(@value))}.each do |removed_item|
            Filtering.remove_from_domain(extension, removed_item)         
          end
        else
          set.each_image.select{|item| !(item.eql?(@value))}.each do |removed_item|
            Filtering.remove_from_image(extension, removed_item)         
          end          
        end
      else        
       build_query_filter(set).relation_equals(@relation, @value)        
      end
      super(extension, set)
    end
    
    def expression
      if(@relation.nil?)
        ".equals(\"#{@value.to_s}\")"
      else
        ".equals(\"#{@relation.to_s}\", \"#{@value.to_s}\")"
      end
    end  
  end
  
  def self.equals(relation = nil, value)
    self.add_filter(Equals.new(relation, value))
    self
  end
end