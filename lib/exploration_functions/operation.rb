module Explorable
  @@cache = {}
  @@use_cache = true

  def self.get_cache
    @@cache
  end
  
  def self.cache(xset)
    @@cache[xset.expression] = xset
  end
  
  def self.get_from_cache(expression)
    @@cache[expression]
  end
  
  def self.use_cache(use_cache_b)
    @@use_cache = use_cache_b
  end
  
  def self.use_cache?
    @@use_cache
  end
  
  
  class Operation  
  
    def update
      execute(@args)
    end
    
    def horizontal?
      return false
    end

    def execute(args={})
      @args = args
      result_set = nil
      mappings = {}
      # binding.pry
      if(Explorable.use_cache?)

        result_set = Explorable.get_from_cache(self.expression)
        
        if(result_set.nil?)
          if(!@args[:input].empty?)         
            mappings = self.eval()
          end
          
          result_set = mount_result_set(mappings)
          
          Explorable.cache(result_set)
        else
          puts "FOUND IN CACHE: #{self.expression}"
        end
      else
        if(!@args[:input].empty?)         
          mappings = self.eval()
        end
        result_set = mount_result_set(mappings)
      end
      result_set
      
    end
    
    def eval
      
    end
  
    def dependencies
      @args.values.flatten.select do |arg|
        arg.is_a? Xset
      end
    end
  
    def validate
      return true
    end
  
    def expression
    end
  
    def mount_result_set(mappings)

      result_set = Xset.new do |s|
        s.extension = mappings
        s.intention = self
        s.server = @args[:input].server
        s.resulted_from = @args[:input]
      end    
      @args[:input].generates << result_set
      result_set.save
      return result_set
    end
  end
  
  def execute_operation(operation_klass, args)
    args[:input] = self
    operation_klass.new.execute args
  end
  
end