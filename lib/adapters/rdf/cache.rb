class RDFCache
  def initialize(size)
    @index = {}
    @max_size = size
  end
  
  def add(index, solution)
    if(@index.size <= @max_size)
      if(!@index.has_key?(index))
        @index[index] = Set.new
      end
      @index[index] << solution
    else
      @index.delete(@index.keys.first)
    end
  end
  
  def get(index)
    @index[index]
  end
  
  def has_entry?(index)
    @index.has_key? index
  end
  
  def size
    @index.size
  end
  
end