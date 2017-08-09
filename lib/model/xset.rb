
class Xset
  include Explorable
  include Indexing
  include Persistable::Writable
  extend Persistable::Readable
  attr_accessor :id, :expression, :v_expression, :index, :server, :resulted_from, :title, :mappings
  
  def initialize(id, expression, v_expression = nil)
    @id = id
    @expression = expression
    @v_expression = v_expression || expression
    @index = Indexing::Entry.new('root')
    @mappings = {}
  end
  
  def literal_extension?
    each_item.first.is_a? Xpair::Literal
  end
  
  def get_cursor(window_size)
    Cursor.new(self, window_size)
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
    @index.empty? && !self.root?
  end
  
  def root?
    @id == "root"
  end
  
  ##Relation Methods##
  def add_mapping(domain, image)
    if(!@mappings.has_key?(domain))
      @mappings[domain] = Set.new
    end
    @mappings[domain] << image
  end
  
  def inverse?
    false
  end
    
  def domain()
    @mappings.keys
  end
  
  def image()
    @mappings.values.flatten
  end
  
  def [](restriction)
    restricted_image_set(restriction)
  end
  
  def restricted_image(restriction, image_items = [], offset = 0, limit = -1)
    res_image = Set.new
    restriction.each do |domain_item|
      if(@mappings.has_key? domain_item)
        res_image += @mappings[domain_item].map{|img| Pair.new(domain_item, img)}
      end
    end
    res_image
  end
  
  def restricted_image_set(restriction, image_items = [], offset = 0, limit = -1)
    res_image = Set.new
    restriction.each do |domain_item|
      res_image += @mappings[domain_item] if(@mappings.has_key? domain_item)
    end
    res_image
  end
  
  def restricted_domain_set(restriction, image_items = [], offset = 0, limit = -1)
    res_domain = Set.new
    restriction.each do |image_item|
      @mappings.each do |domain, image_set|
        res_domain << domain if image_set.include?(image_item)
      end
    end
    res_domain
  end
 alias text title
  
end