module Filtering
  class Match < Filtering::Filter
    def initialize(*args)
      super(args)
      
      if args.size == 1
        @value = args[0]
      elsif args.size == 2
        @relation = args[0]
        @pattern = args[1]
      else
        raise "Invalid number of arguments. Expected: min 1, max 2; Received: #{args.size}"
      end      
      
    end
    
    def eval(set)
      extension = set.extension_copy
      
      if(@relation.nil?)
        if set.empty_image?
          set.each_domain.select{|item| item.to_s.match(/#{@pattern}/).nil?}.each do |removed_item|        
            Filtering.remove_from_domain(extension, removed_item) 
          end          
        else
          set.each_image.select{|item| item.to_s.match(/#{@pattern}/).nil?}.each do |removed_item|        
            Filtering.remove_from_image(extension, removed_item) 
          end          
        end
      else
        
        build_query_filter(set).relation_regex(@relation, @pattern)
      end
      super(extension, set)
    end
    
    def expression
      if @relation.nil?
        ".match(\"#{@pattern}\")"
      else
        ".match(\"#{relation.to_s}\", \"#{@pattern}\")"
      end      
    end
  end
  
  def self.match(relation=nil, value)
    self.add_filter(Match.new(relation, value))
    self
  end
end