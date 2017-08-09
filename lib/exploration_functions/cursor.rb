class Cursor

  attr_accessor :operation, :window_size, :result_set, :pages_cache
  def initialize(xset, window_size = 20)
    @operation = xset.intention
    @window_size = window_size
    @limit = window_size
    @offset = 0
    @page = 0
    @pages_cache = {}
    @result_set = xset
  end
  
  
  def generate_result_set
    if(Explorable.use_cache?)
      cached_result = Explorable.get_from_cache(self.operation.expression)
      if(!cached_result)
        result_set = operation.get_result_set()
        Explorable.cache(result_set)
      end
    else
      result_set = operation.get_result_set()
    end
    result_set.save
    result_set
  end
  
  def next_page
    if(@page == 1)
      return @result_set.index.indexed_items
    end
    @page += 1
    @offset += @limit      
    @result_set.index = @operation.execute(@offset, @limit)
    @result_set.index.indexed_items
  end
  
  def get_page(page_number)
    if(@pages_cache.has_key?(page_number))
      @result_set.index = @pages_cache[page_number]
      return @result_set.index.indexed_items
    end
    return [] if(page_number < 1)
    
    pg_offset = 0
    
    (page_number - 1).times{|pg| pg_offset += @limit}
    items_to_filter = @pages_cache.values.map{|i| i.indexed_items}.flatten
    binding.pry
    @pages_cache[page_number] = @operation.execute(pg_offset - items_to_filter.size, @limit, items_to_filter)
    @result_set.index = @pages_cache[page_number]
    @result_set.index.indexed_items
  end
  
end