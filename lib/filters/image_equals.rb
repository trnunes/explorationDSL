module Filtering
  class ImageEquals < Filtering::Filter
    def initialize(*args)
      super(args)
      
      if args.size == 1
        @value = args[0]
      elsif args.size == 2
        @relations = args[0]
        @value = args[1]
      else
        raise "Invalid number of arguments. Expected: min 1, max 2; Received: #{args.size}"
      end      
    end
    
    def eval(set)
      extension = set.extension_copy

      set.each do |item|
        puts "ITEM " << item.inspect
        leaves = HashHelper.leaves(set.trace_image(item, set.order_relations(@relations.dup)))
        puts "LEAVES: " << leaves.inspect
        puts "VALUE: " << @value.inspect
        if !leaves.include? @value
          extension.delete(item)
        end
      end
      super(extension, set)
    end
    
    def expression
      if(@relation.nil?)
        ".equals(\"#{@value.to_s}\")"
      else
        ".equals(\"#{@relations.to_s}\", \"#{@value.to_s}\")"
      end
    end  
  end
  
  def self.image_equals(args)
    if args[:relations].nil?
      raise "Missing relations for filter!"
    end
    if args[:values].nil?
      raise "Missing values for filter!"
    end
    self.add_filter(ImageEquals.new(args[:relations], args[:values]))
    self
  end
end