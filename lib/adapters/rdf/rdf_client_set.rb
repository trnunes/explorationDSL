
require 'rdf'
require 'linkeddata'
require './model/entity.rb'
require 'sparql/client'
load './adapters/filter.rb'

class RdfClientSet
  attr_accessor :server
  attr_accessor :intention, :extension, :id
  @@limit = 5000
  @@USE_CURSOR = false
  
  def self.use_cursor
    @@USE_CURSOR = true
  end
  
  def select(range)
    result_set = RdfClientSet.new()    
    result_set.extension = self.extension[range]
    result_set.intention = "#{self.intention}.select(#{range})"
    result_set    
  end
  
  def [](index)
    @extension[index]
  end
  
  def initialize(id=nil)
    @id = id
    @server = SPARQL::Client.new(RDF::Graph.new)
    @extension = []
    @intention = "RdfClientSet.load(\"#{@id}\")"    
  end
  
  def server=(server)
    @server = server
  end  
  
  def self.load(id)
    return RdfClientSet.new
  end  
  
  def << (item)
    @extension << item
  end
  # test if the set is not a result of an exploration operations.
  def root_set?
   @intention.eql?("RdfClientSet.load(\"#{id}\")")
  end
  
  def to_uri(entity)
    RDF::URI.new(entity.to_s)
  end
  
  def eql?(other)
    other.class == self.class && other.extension.eql?(self.extension) && other.intention == self.intention
  end
  
  alias_method :==, :eql?
  # def extension
#     
#     if @extension.empty?
#       each
#     end
#     @extension
#end

  #TODO implementar
  def include?(item)
    extension.flatten.include?(item)
  end
  
  def execute_query(query, &block)
    offset = 0
    result_array = []
    more_elements = true
    while more_elements          

      
      more_elements = false
      query.offset(offset).limit(@@limit).each_solution do |solution|
        more_elements = true if @@USE_CURSOR
        # 
        if block_given?
          
          yield solution
        end
      end
      offset += @@limit
    end
    
  end
  
  def relations
    result_set = RdfClientSet.new()
    if(root_set?)
      result_set.extension = @server.all_relations()
    else
      each{|item| result_set.extension += @server.find_relations(item)}
    end

    result_set.intention = "#{self.intention}.relations"
    result_set
  end
  
  def last_uri_part(uri)
    label = uri.include?("#")? uri.split("#").last : uri.split("/").last
  end

  def each(&block)
    if(@extension.empty?)
      if(root_set?)
        @server.each_item do |item| 
          yield(item)
          @extension << item
        end
      end
    else
      @extension.each &block
    end
    self
  end
  
  def pivot(relations)
    result_set = RdfClientSet.new()

    restricted_domain_pairs = []
    pairs_by_subject_by_relation = {}
    visited = []
    results_by_subject = []

    query = @server.begin_query do |q|    
      each do |item|
        relations.each do |r|
          q.restricted_image(item, r)
        end
      end    
    end

    results_hash = query.execute

    results_hash.each_key do |subject|
      results_hash[subject].each_key do |relation|
        result_set.extension += results_hash[subject][relation]
      end
    end
        
    relation_expression = relations.map{|r| r.to_s}.inspect
    # #TODO correct!
    result_set.intention = "#{self.intention}.pivot(#{relation_expression})"
    return result_set
  end
  
  def refine(&block)
    
    result_set = RdfClientSet.new()
    f = Filter.new(self)
    yield(f)
    result_set.extension = f.eval
    result_set.intention = "#{self.intention}.refine#{f.expression}"
    result_set
  end
  
  def group(relation)    
    result_set = RdfClientSet.new

    query = @server.begin_query do |q|
      each do |item|
        q.restricted_image(item, relation.first)
      end
    end
    groups_hash = {}
    results_hash = query.execute
    results_hash.each_key do |subject|
      objects = results_hash[subject][Entity.new(relation.first)]
      objects ||= []
      objects.each do |object|
        if groups_hash[object].nil?
          groups_hash[object] = []
        end      
        groups_hash[object] << subject        
      end      
    end    
    
    groups_hash.each do |grouping_item, grouped_items|
      group_set = RdfClientSet.new(grouping_item.to_s)      
      group_set.extension = grouped_items      
      result_set << [grouping_item, group_set]
    end
    result_set.intention = "#{self.intention}.group([\"#{relation.first.to_s}\"])"
    result_set    
  end
  
  def map(mappingFunction)
    result_set = RdfClientSet.new
    result = nil
    each{|item| result = mappingFunction.call(item)}
    result_set.intention = "#{self.intention}.map(#{mappingFunction.name})"
    if (result.is_a?(Array))      
      result_set.extension = result
    else
      result_set.extension = [result]
    end
    result_set
  end
  
  def union(set)
    result_set = RdfClientSet.new
    result_set.extension = self.extension + set.extension
    result_set.intention = "#{self.intention}.union(#{set.intention})"
    result_set
  end  

  def intersect(target_set)
    result_set = RdfClientSet.new()
    result_set.extension = target_set.extension & self.extension
    result_set.intention = "#{self.intention}.intersect(#{target_set.intention})"
    result_set
  end
  
  def diff(set)
    result_set = RdfClientSet.new()
    result_set.extension = self.extension - set.extension
    result_set.intention = "#{self.intention}.diff(#{set.intention})"
    result_set
  end
  
  
end