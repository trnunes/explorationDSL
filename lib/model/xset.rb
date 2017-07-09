
class Xset
  include Explorable
  include Indexing
  include Persistable::Writable
  extend Persistable::Readable
  attr_accessor :id, :expression, :v_expression, :index, :server, :resulted_from, :title
  
  def initialize(id, expression, v_expression = nil)
    @id = id
    @expression = expression
    @v_expression = v_expression || expression
    @index = Indexing::Entry.new('root')
  end
  
  def literal_extension?
    each_item.first.is_a? Xpair::Literal
  end
    
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
  
  def natural_sort!
    @index.natural_sort!
  end
  
  def each(&block)
    each_item &block
  end
  
  def empty?
    @index.empty?
  end
  
end