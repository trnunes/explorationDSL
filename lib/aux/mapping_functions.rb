module MappingFunctions
  module Types
    AGGREGATOR = 0
    COMBINATORIAL = 1
    TRANSFORMATIONAL = 2
  end
  
  class Function
    attr_accessor :name, :mappings, :type, :origin_set

    def initialize(name)
      @name = name
    end

    def map(*items)
    end      
  end
  
  class Average < Function
    
    TYPE = Types::AGGREGATOR
    def initialize()
      super("avg")
      @sum = 0
      @count = 0
      @mapped_items = []
    end
      
    def map(*items)
      items.each do |item|
        @sum += item.value
        @count += 1
        @mapped_items << item
      end      
    end
    
    def mappings
      avg = Literal.new(@sum/@count)
      mappings = {}
      mappings[avg] ||= {}
      @mapped_items.each do |item|        
        mappings[avg] = {}
      end
      @mapped_items = []
      @sum = 0
      @count = 0
      mappings
    end
  end
  
  class Count < Function    
    TYPE = Types::AGGREGATOR
    def initialize()
      super("count")
      @count = 0
      @mapped_items = []
    end
      
    def map(*items)
      items.each do |item|
        @count += 1
        @mapped_items << item
      end      
    end
    
    def mappings      
      mappings = {Literal.new(@count) => {}}
      @mapped_items.each do |item|        
        mappings[Literal.new(@count)] = {}
      end
      @mapped_items = []
      @count = 0
      mappings
    end
  end
  
  class DomainCount < Function
    
    TYPE = Types::AGGREGATOR
    attr_accessor :origin_set
    def initialize(target_set)
      super("domain_count")
      @counts_by_image={}
      @target_set = target_set
    end
    
    
    def map(*items)
      image_set = Set.new()
      
      items.each do |item|
        item_image = @target_set.each_domain([item])
        if !item_image.nil?
          image_set.merge(item_image)
        end        
        @counts_by_image[image_set.size] ||={}

      end
    end
    
    def mappings
      @counts_by_image
    end
    
  end
  
  def self.count
    count = 0    
    return Count.new()
  end
  
  def self.avg
    return Average.new()
  end
  
  def self.domain_count(target_set)
    return DomainCount.new(target_set)
  end
end