require 'java'

# 'java_import' is used to import java classes
java_import 'java.util.concurrent.Callable'
java_import 'java.util.concurrent.FutureTask'
java_import 'java.util.concurrent.LinkedBlockingQueue'
java_import 'java.util.concurrent.ThreadPoolExecutor'
java_import 'java.util.concurrent.TimeUnit'

module Filtering
  
  class ConcurrentImageEquals
    include Callable

    def initialize(origin_set, copy_set, relations, images, values, connector)
      @images = images
      @set = origin_set
      @copy_set = copy_set
      @relations = relations
      @values = values
      @connector = connector
    end
    
    def call
      # binding.pry 
      @images.each do |item|
        
        image_set = @set.trace_image_items(item, @relations.dup)
        # binding.pry
        
        if @values.size == 1
          if !image_set.include?(@values.first)
            @copy_set.remove_item(item)
          end          
        else
          if(@connector == "AND")
            if !(@values - image_set).empty?
              @copy_set.remove_item(item)
            end
          else
            if (@values & image_set).empty?
              @copy_set.remove_item(item)
            end
          end
        end     
      end
    end
  end
  
  class ImageEquals < Filtering::Filter
    
    def initialize(*args)
      super(args)
      @relations = args[0]
      @values = args[1].nil? ? args[0] : args[1]
      if !@values.respond_to? :each
        @values = [@values]
      end
      @connector = args[2]
      if @connector.nil?
        @connector = "AND"
      end
    end
    
    def eval(set)
      set.paginate(100)
      if(!set.nil? && !set.empty?)
        executor = ThreadPoolExecutor.new(set.count_pages, # core_pool_treads
                                          set.count_pages, # max_pool_threads
                                          10000000000, # keep_alive_time
                                          TimeUnit::SECONDS,
                                          LinkedBlockingQueue.new)
        puts "NUMBER OF THREADS: " << set.count_pages.to_s
                                        
        set_copy = Xset.new{|s| s.extension = set.extension_copy}
        relations = set.order_relations(@relations.dup)
        tasks = []
        (1..set.count_pages).each do |i|

          task = FutureTask.new(ConcurrentImageEquals.new(set, set_copy, relations, set.each_image(page: i), @values, @connector))
          executor.execute(task)
          tasks << task
        end
      
        tasks.each do |t|
          t.get
        end
        executor.shutdown()
        #
        #
        # # binding.pry
        # set.each_image do |item|
        #   relations = set.order_relations(@relations.dup)
        #
        #   image_set = set.trace_image_items(item, set.order_relations(@relations.dup))
        #   # if(item.id == "http://data.semanticweb.org/workshop/cold/2011/proceedings")
        #   #   binding.pry
        #   # end
        #
        #
        #   if !image_set.include?(@value)
        #
        #
        #
        #     set_copy.remove_item(item)
        #   end
        # end
        set_copy.extension
      end
    end
    
    def expression
      if(@relation.nil?)
        ".equals(\"#{@values.to_s}\")"
      else
        ".equals(\"#{@relations.to_s}\", \"#{@values.to_s}\")"
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
    
    self.add_filter(ImageEquals.new(args[:relations], args[:values], args[:connector]))
    self
  end
end