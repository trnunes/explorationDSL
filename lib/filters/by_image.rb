module Filtering
  class ImageFilter < Filtering::Filter
    
    def initialize(args={})
      # binding.pry
      super(args)
      
      @restriction = args[:restriction]
    end
    
    # def eval(set)
    #   build_query_filter(set).compare(@relations, @operator, @value)
    #   super(set.extension_copy, set)
    # end
    def prepare(items, server)
    end
    
    def filter(item)
      # binding.pry
      !eval(@restriction)
    end
    
    def expression
      "by_image(rescriction: #{@restriction})"
    end
  end
  
  
  
  def self.by_image(args)
    if args[:restriction].nil?
      raise "MISSING VALUE FOR FILTER!"
    end
    self.add_filter(ImageFilter.new(args))
    self
  end
end
