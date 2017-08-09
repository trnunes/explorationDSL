require 'set'
module Xenumerable  

  
  def each_domain(&block)
    domains = Set.new
    each_item do |item|
      domains << item.index.indexing_item if item.index.indexing_item != 'root'
    end
    if block_given?
      domains.each &block
    end
    domains.to_a.sort{|d1, d2| d1.to_s <=> d2.to_s}
  end
  def each(&block)
    each_item &block
  end
  
  def empty?
    @index.empty?
  end
  
  def root?
    @id == "root"
  end
    
end
