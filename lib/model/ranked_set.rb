
class RankedSet < Xset
  #TODO ranked sets always preserver the order. 
  # Any operation over a ranked set should return another ranked set ranked by the same criteria of the original
  attr_accessor :ranking_function, :ranked_extension
  
  def initialize(xset, ranking_function=nil)
    super()
    @inverted_hash = xset.pivot.extension
    
    @ranking_function = ranking_function
    
    @resulted_from = xset
    @extension = @resulted_from.extension
    if @ranking_function.nil?
      @ranked_extension = @resulted_from.each_image.sort{|item1, item2| item1.to_s <=> item2.to_s}
    else
      @ranked_extension = @resulted_from.each_image.sort do |item1, item2| 
        (@ranking_function.score(item1) <=> @ranking_function.score(item2)) * -1
      end
    end
  end
  
  def each(&block)    
    @ranked_extension.each &block      
    self
  end
  
  def remove(item)
    @ranked_extension.delete(item)
    self
  end
  
  def each_domain(set = nil)

    domain = @resulted_from.each_domain(set).to_a
    domain.sort!{|d1, d2| @ranked_extension.index(@resulted_from.extension[d1].to_a.first) <=> @ranked_extension.index(@resulted_from.extension[d2].to_a.first)}
    domain    
  end
  
  def each_image(set = nil)
    @resulted_from.each_image(set)
  end
  
  def mount_result_set(intention, mappings, bindings)    
    return RankedSet.new(super.mount_result_set(intention, mappings, bindings), @ranking_function)
  end
end